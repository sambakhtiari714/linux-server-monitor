
import json
import sys
from pathlib import Path

from pydantic import ValidationError

from models import IncidentReport


def validate(path: str) -> IncidentReport:
    raw_text = Path(path).read_text()
    data = json.loads(raw_text)
    return IncidentReport.model_validate(data)


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else "output/incidents.json"

    try:
        report = validate(path)
    except FileNotFoundError:
        print(f" فایل پیدا نشد: {path}")
        return 1
    except json.JSONDecodeError as e:
        print(f" فایل JSON معتبر نیست: {e}")
        return 1
    except ValidationError as e:
        print(f" {path} با schema مطابقت ندارد:")
        print(e)
        return 1

    print(f" {path} معتبر است")
    print(f"   overall_status : {report.overall_status}")
    print(f"   تعداد سرویس‌ها  : {len(report.services)}")
    for service in report.services:
        print(f"     - {service.name}: {service.status} / {service.severity}")

    return 0


if __name__ == "__main__":
    sys.exit(main())