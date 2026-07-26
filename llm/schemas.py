from typing import Optional

from pydantic import BaseModel


class DetailedFinding(BaseModel):
    """تحلیل کامل برای یک مورد با severity=HIGH یا CRITICAL."""

    component: str
    severity: str
    root_cause: str
    risk: str
    fix_commands: list[str]


class BriefNote(BaseModel):
    """یک خط توضیح برای یک مورد با severity پایین‌تر."""

    component: str
    severity: str
    note: str
    suggestion: Optional[str] = None


class AnalysisReport(BaseModel):
    """کل خروجی نهایی مدل، بعد از اعتبارسنجی."""

    overall_summary: str
    detailed_findings: list[DetailedFinding]
    brief_notes: list[BriefNote]
