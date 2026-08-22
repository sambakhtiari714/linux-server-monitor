import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.append(str(ROOT / "python"))
sys.path.append(str(ROOT / "llm"))

import json

from models import IncidentReport
from analyzer import get_valid_analysis

from report_generator import render_cli, save_markdown


def main() -> int:
    incidents_path = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / "output" / "incidents.json")

    data = json.loads(Path(incidents_path).read_text())
    report = IncidentReport.model_validate(data)

    analysis = get_valid_analysis(report)

    print(render_cli(analysis))

    md_path = ROOT / "reports" / "analysis.md"
    save_markdown(analysis, str(md_path), hostname=report.hostname, generated_at=report.generated_at)
    print(f"\nگزارش Markdown ذخیره شد در: {md_path}")

    return 0


if __name__ == "__main__":
    sys.exit(main())