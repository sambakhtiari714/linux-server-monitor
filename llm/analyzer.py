import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "python"))

from models import IncidentReport
from openrouter_client import call_llm
from prompt_builder import build_prompt, build_repair_prompt
from response_parser import (
    parse_analysis_response,
    JSONSyntaxError,
    SchemaValidationError,
    ResponseParseError,
)
from schemas import AnalysisReport

DEBUG_DIR = Path(__file__).resolve().parent.parent / "reports" / "debug"


def _save_raw_response(raw_text: str) -> Path:
    DEBUG_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    path = DEBUG_DIR / f"raw_response_{timestamp}.txt"
    path.write_text(raw_text, encoding="utf-8")
    return path


def get_valid_analysis(report: IncidentReport, max_retries: int = 3) -> AnalysisReport:
    prompt = build_prompt(report)
    total_attempts = max_retries + 1
    last_error: Exception | None = None

    for attempt in range(1, total_attempts + 1):
        request_start = time.time()
        raw_text = call_llm(prompt)
        elapsed = time.time() - request_start
        print(f"[analyzer] تلاش {attempt}/{total_attempts} | مدت پاسخ: {elapsed:.1f}s")

        try:
            analysis = parse_analysis_response(raw_text)
            print(f"[analyzer] تلاش {attempt}: parse=OK validation=OK")
            return analysis

        except JSONSyntaxError as e:
            print(f"[analyzer] تلاش {attempt}: parse=FAILED (JSON نامعتبر)")
            saved_path = _save_raw_response(raw_text)
            print(f"[analyzer]   پاسخ خام ذخیره شد: {saved_path}")
            last_error = e

            repair_prompt = build_repair_prompt(raw_text)
            try:
                repaired_text = call_llm(repair_prompt)
                analysis = parse_analysis_response(repaired_text)
                print(f"[analyzer] تلاش {attempt}: Repair=OK")
                return analysis
            except ResponseParseError:
                print(f"[analyzer] تلاش {attempt}: Repair=FAILED")

        except SchemaValidationError as e:
            print(f"[analyzer] تلاش {attempt}: parse=OK validation=FAILED")
            saved_path = _save_raw_response(raw_text)
            print(f"[analyzer]   پاسخ خام ذخیره شد: {saved_path}")
            last_error = e

        if attempt < total_attempts:
            wait_seconds = 2 ** (attempt - 1)
            print(f"[analyzer]   {wait_seconds} ثانیه صبر و تلاش دوباره...")
            time.sleep(wait_seconds)

    raise ResponseParseError(
        f"بعد از {total_attempts} تلاش، پاسخ معتبری از مدل گرفته نشد: {last_error}"
    )