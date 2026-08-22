import json
from pydantic import ValidationError
from schemas import AnalysisReport


class ResponseParseError(Exception):
    pass


class JSONSyntaxError(ResponseParseError):
    pass


class SchemaValidationError(ResponseParseError):
    pass


def strip_markdown_fence(text: str) -> str:
    text = text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        text = "\n".join(lines)
    return text.strip()


def parse_analysis_response(raw_text: str) -> AnalysisReport:
    cleaned = strip_markdown_fence(raw_text)

    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as e:
        raise JSONSyntaxError(f"جواب مدل JSON معتبر نبود: {e}")

    try:
        return AnalysisReport.model_validate(data)
    except ValidationError as e:
        raise SchemaValidationError(f"جواب مدل با schema مطابقت نداشت:\n{e}")