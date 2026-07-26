import json

from pydantic import ValidationError

from schemas import AnalysisReport


class ResponseParseError(Exception):
    """جواب مدل نه JSON معتبر بود، نه با schema ما مطابقت داشت."""


def _strip_markdown_fence(text: str) -> str:
    """
    بعضی مدل‌ها با اینکه گفتیم "بدون ```json"، بازم اینطوری جواب می‌دن:
        ```json
        { ... }
        ```
    این تابع، اگه این حالت رو ببینه، فقط خود JSON داخلش رو نگه می‌داره.
    """
    text = text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        lines = lines[1:]  # خط اول (```json یا ```) را حذف کن
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]  # خط آخر (```) را هم حذف کن
        text = "\n".join(lines)
    return text.strip()


def parse_analysis_response(raw_text: str) -> AnalysisReport:
    cleaned = _strip_markdown_fence(raw_text)

    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as e:
        raise ResponseParseError(f"جواب مدل JSON معتبر نبود: {e}\n\nمتن خام:\n{raw_text}")

    try:
        return AnalysisReport.model_validate(data)
    except ValidationError as e:
        raise ResponseParseError(f"جواب مدل با schema مطابقت نداشت:\n{e}")
