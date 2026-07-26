import sys
from pathlib import Path


sys.path.append(str(Path(__file__).resolve().parent.parent / "python"))

from fastapi import FastAPI

from models import IncidentReport

app = FastAPI()


@app.post("/analyze")
def analyze(report: IncidentReport):
    return {
        "hostname": report.hostname,
        "overall_status": report.overall_status,
        "service_count": len(report.services),
        "services": [service.name for service in report.services],
    }