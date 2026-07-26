import sys
from datetime import datetime
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "llm"))

from schemas import AnalysisReport

RED = "\033[0;31m"
YELLOW = "\033[1;33m"
GREEN = "\033[0;32m"
NC = "\033[0m"

SEVERITY_COLOR = {
    "CRITICAL": RED,
    "HIGH": RED,
    "MEDIUM": YELLOW,
    "LOW": GREEN,
    "OK": GREEN,
}


def render_cli(report: AnalysisReport) -> str:
    lines = []
    lines.append("=" * 50)
    lines.append("گزارش تحلیل سرور")
    lines.append("=" * 50)
    lines.append(f"خلاصه: {report.overall_summary}")
    lines.append("")

    if report.detailed_findings:
        lines.append("--- موارد نیازمند بررسی فوری ---")
        for finding in report.detailed_findings:
            color = SEVERITY_COLOR.get(finding.severity, NC)
            lines.append(f"{color}[{finding.severity}] {finding.component}{NC}")
            lines.append(f"  علت ریشه‌ای : {finding.root_cause}")
            lines.append(f"  ریسک        : {finding.risk}")
            lines.append("  دستورها     :")
            for cmd in finding.fix_commands:
                lines.append(f"    $ {cmd}")
            lines.append("")

    if report.brief_notes:
        lines.append("--- بقیه‌ی موارد ---")
        for note in report.brief_notes:
            color = SEVERITY_COLOR.get(note.severity, NC)
            suggestion = f" (پیشنهاد: {note.suggestion})" if note.suggestion else ""
            lines.append(f"{color}[{note.severity}]{NC} {note.component}: {note.note}{suggestion}")

    return "\n".join(lines)


def render_markdown(report: AnalysisReport, hostname: str = "", generated_at: str = "") -> str:
    lines = []
    lines.append("# گزارش تحلیل سرور")
    if hostname:
        lines.append(f"**هاست:** {hostname}  ")
    lines.append(f"**تاریخ تولید گزارش:** {generated_at or datetime.now().isoformat()}  ")
    lines.append("")
    lines.append("## خلاصه")
    lines.append(report.overall_summary)
    lines.append("")

    if report.detailed_findings:
        lines.append("## موارد نیازمند بررسی فوری")
        for finding in report.detailed_findings:
            lines.append(f"### {finding.component} — `{finding.severity}`")
            lines.append(f"- **علت ریشه‌ای:** {finding.root_cause}")
            lines.append(f"- **ریسک:** {finding.risk}")
            lines.append("- **دستورها:**")
            for cmd in finding.fix_commands:
                lines.append(f"  ```bash\n  {cmd}\n  ```")
            lines.append("")

    if report.brief_notes:
        lines.append("## بقیه‌ی موارد")
        lines.append("")
        lines.append("| سرویس | Severity | توضیح | پیشنهاد |")
        lines.append("|---|---|---|---|")
        for note in report.brief_notes:
            suggestion = note.suggestion or "—"
            lines.append(f"| {note.component} | {note.severity} | {note.note} | {suggestion} |")

    return "\n".join(lines)


def save_markdown(report: AnalysisReport, path: str, hostname: str = "", generated_at: str = "") -> None:
    content = render_markdown(report, hostname=hostname, generated_at=generated_at)
    Path(path).write_text(content, encoding="utf-8")
