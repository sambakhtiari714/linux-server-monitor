import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "python"))

from models import IncidentReport, Metric, Service

DETAILED_SEVERITIES = {"HIGH", "CRITICAL"}


def _needs_detailed_analysis(severity: str) -> bool:
    return severity in DETAILED_SEVERITIES


def _describe_metric(name: str, metric: Metric) -> str:
    return f"- {name}: usage={metric.usage_percent}%, status={metric.status}, severity={metric.severity}"


def _describe_service(service: Service) -> str:
    if service.status == "OK":
        return f"- {service.name}: سالم (OK), severity=OK"

    if _needs_detailed_analysis(service.severity):
        lines_preview = "; ".join(service.matched_lines) if service.matched_lines else "(no matched lines)"
    else:
        lines_preview = "; ".join(service.matched_lines[:3]) if service.matched_lines else "(no matched lines)"

    return (
        f"- {service.name}: DOWN, severity={service.severity}, "
        f"critical_pattern_matched={service.critical_pattern_matched}, "
        f"score={service.score}, pattern_state={service.pattern_state}, "
        f"log_level={service.log_level}, "
        f"errors={service.error_count}, warnings={service.warning_count}, "
        f"failed={service.failed_count}, timeouts={service.timeout_count}, "
        f"matched_lines=[{lines_preview}]"
    )


def build_prompt(report: IncidentReport) -> str:
    all_metrics = [
        ("disk", report.system.disk),
        ("ram", report.system.ram),
        ("cpu", report.system.cpu),
    ]

    detailed_lines: list[str] = []
    brief_lines: list[str] = []

    for name, metric in all_metrics:
        line = _describe_metric(name, metric)
        if _needs_detailed_analysis(metric.severity):
            detailed_lines.append(line)
        else:
            brief_lines.append(line)

    for service in report.services:
        line = _describe_service(service)
        if _needs_detailed_analysis(service.severity):
            detailed_lines.append(line)
        else:
            brief_lines.append(line)

    detailed_block = "\n".join(detailed_lines) if detailed_lines else "(هیچ موردی با اولویت بالا نیست)"
    brief_block = "\n".join(brief_lines) if brief_lines else "(هیچ موردی نیست)"

    prompt = f"""تو یک متخصص لینوکس و DevOps هستی که یک گزارش مانیتورینگ سرور را بررسی می‌کنی.

هاست: {report.hostname}
زمان گزارش: {report.generated_at}
وضعیت کلی: {report.overall_status}

## بخش ۱ - موارد با اولویت بالا (severity = HIGH یا CRITICAL)
{detailed_block}

## بخش ۲ - بقیه‌ی موارد (severity پایین‌تر)
{brief_block}

## فرمت خروجی — این خیلی مهم است
فقط و فقط یک JSON معتبر برگردان، بدون هیچ متن اضافه قبل یا بعدش،
بدون ```json و بدون توضیح، دقیقاً با این ساختار:

{{
  "overall_summary": "یک یا دو جمله خلاصه کلی وضعیت سرور",
  "detailed_findings": [
    {{
      "component": "اسم سرویس یا متریک",
      "severity": "HIGH یا CRITICAL",
      "root_cause": "علت ریشه‌ای احتمالی",
      "risk": "توضیح سطح ریسک",
      "fix_commands": ["دستور اول", "دستور دوم"]
    }}
  ],
  "brief_notes": [
    {{
      "component": "اسم سرویس یا متریک",
      "severity": "OK یا LOW یا MEDIUM",
      "note": "یک خط توضیح وضعیت",
      "suggestion": "فقط اگر واقعا لازم است، وگرنه null"
    }}
  ]
}}

اگر بخش ۱ خالی بود، detailed_findings را آرایه‌ی خالی [] بگذار.
اگر بخش ۲ خالی بود، brief_notes را آرایه‌ی خالی [] بگذار.
"""
    return prompt


def build_repair_prompt(raw_text: str) -> str:
    return f"""متن زیر باید یک JSON معتبر باشد ولی معتبر نیست.

وظیفه تو فقط این است: ساختار JSON را اصلاح کن.
هیچ اطلاعاتی اضافه یا حذف نکن.
هیچ تحلیل جدیدی انجام نده.
فقط و فقط JSON معتبر خروجی بده، بدون ```json، بدون هیچ توضیح اضافه.

متن ورودی:
{raw_text}
"""