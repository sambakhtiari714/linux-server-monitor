import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "python"))

from models import IncidentReport
from response_parser import SemanticValidationError
from schemas import AnalysisReport


def _severity_map(report: IncidentReport) -> dict[str, str]:
    severities = {
        "disk": report.system.disk.severity,
        "ram": report.system.ram.severity,
        "cpu": report.system.cpu.severity,
    }
    for service in report.services:
        severities[service.name] = service.severity
    return severities


def validate_semantics(analysis: AnalysisReport, report: IncidentReport) -> None:
    severity_by_component = _severity_map(report)
    known_components = set(severity_by_component.keys())
    errors: list[str] = []

    for finding in analysis.detailed_findings:
        if finding.component not in known_components:
            errors.append(f"component ناشناخته در detailed_findings: {finding.component}")
        elif finding.severity != severity_by_component[finding.component]:
            errors.append(
                f"severity نادرست برای {finding.component}: "
                f"مدل نوشته {finding.severity}, ورودی {severity_by_component[finding.component]} بود"
            )

    for note in analysis.brief_notes:
        if note.component not in known_components:
            errors.append(f"component ناشناخته در brief_notes: {note.component}")
        elif note.severity != severity_by_component[note.component]:
            errors.append(
                f"severity نادرست برای {note.component}: "
                f"مدل نوشته {note.severity}, ورودی {severity_by_component[note.component]} بود"
            )

    reported_components = {f.component for f in analysis.detailed_findings} | {
        n.component for n in analysis.brief_notes
    }
    for component, severity in severity_by_component.items():
        if severity in {"HIGH", "CRITICAL"} and component not in reported_components:
            errors.append(f"{component} با severity={severity} در خروجی مدل گم شده است")

    if errors:
        raise SemanticValidationError("؛ ".join(errors))