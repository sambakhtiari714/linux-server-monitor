import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.append(str(ROOT / "python"))
sys.path.append(str(ROOT / "llm"))

import json

from models import IncidentReport
from openrouter_client import call_llm
from prompt_builder import build_prompt
from response_parser import parse_analysis_response

from report_generator import render_cli, save_markdown


def main() -> int:
    incidents_path = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / "output" / "incidents.json")

    data = json.loads(Path(incidents_path).read_text())
    report = IncidentReport.model_validate(data)

    prompt = build_prompt(report)
    raw_answer = call_llm(prompt)
    analysis = parse_analysis_response(raw_answer)

    print(render_cli(analysis))

    md_path = ROOT / "reports" / "analysis.md"
    save_markdown(analysis, str(md_path), hostname=report.hostname, generated_at=report.generated_at)
    print(f"\nگزارش Markdown ذخیره شد در: {md_path}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
