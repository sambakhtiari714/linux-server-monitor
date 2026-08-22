import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "python"))
sys.path.append(str(Path(__file__).resolve().parent.parent / "llm"))

from fastapi import FastAPI, HTTPException

from models import IncidentReport
from analyzer import get_valid_analysis
from response_parser import ResponseParseError
from openrouter_client import OpenRouterError

app = FastAPI()


@app.post("/analyze")
def analyze(report: IncidentReport):
    try:
        analysis = get_valid_analysis(report)
    except OpenRouterError as e:
        raise HTTPException(status_code=502, detail=f"خطا در ارتباط با OpenRouter: {e}")
    except ResponseParseError as e:
        raise HTTPException(status_code=502, detail=f"مدل پاسخ معتبری نداد: {e}")

    return analysis