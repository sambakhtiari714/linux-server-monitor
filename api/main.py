import sys
from pathlib import Path

# python/ و api/ دو پوشه‌ی جدا هستن. این خط به پایتون می‌گه
# «برو تو پوشه‌ی python/ هم دنبال فایل بگرد»، تا بتونیم models.py رو import کنیم.
sys.path.append(str(Path(__file__).parent.parent / "python"))

from fastapi import FastAPI, HTTPException
from pydantic import ValidationError

from models import IncidentReport

app = FastAPI()

# مسیر فایلی که Bash می‌سازه، نسبت به ریشه‌ی پروژه
INCIDENTS_PATH = Path(__file__).parent.parent / "output" / "incidents.json"


@app.get("/analyze")
def analyze():
    if not INCIDENTS_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"فایل {INCIDENTS_PATH} پیدا نشد. اول ./monitor.sh رو اجرا کن.",
        )

    raw_text = INCIDENTS_PATH.read_text()

    try:
        report = IncidentReport.model_validate_json(raw_text)
    except ValidationError as e:
        raise HTTPException(
            status_code=422,
            detail=f"incidents.json با schema مطابقت ندارد: {e}",
        )

    return report