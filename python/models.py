from typing import Literal, Optional
from pydantic import BaseModel, Field

Severity = Literal["OK", "LOW", "MEDIUM", "HIGH", "CIRITICAL"]

class Metric(BaseModel):
    model_config = {"extra" : "forbid"}
    usage_percent: float = Field(ge=0, le=100)
    status: Literal["OK", "WARNING", "CIRITICAL"]
    severity: Severity


class SystemMetrics(BaseModel):
    model_config = {"extra" : "forbid"}

    disk: Metric
    ram: Metric
    cpu: Metric


class Service(BaseModel):
    model_config = {"extra" : "forbid"}

    name: str
    status: Literal["OK", "DOWN"]
    severity: Severity
    critical_pattern_matched: bool

    score: Optional[int] = None
    pattern_state: Optional[
        Literal[
            "OK",
            "ERROR",
            "WARNING",
            "NO_LOGS_FOUND",
            "SERVICE_NOT_INSTALLED",
            "ACCESS_DENIED"

        ]
    ] = None
    log_level: Optional[Literal["FATAL","ERROR","WARNING", "INFO"]] = None
    error_count: Optional[int] = Field(default=None, ge=0)
    warning_count: Optional[int] = Field(default=None, ge=0)
    failed_count: Optional[int] = Field(default=None, ge=0)
    timeout_count: Optional[int] = Field(default=None, ge=0)
 
    matched_lines: list[str] = []
 
 
class IncidentReport(BaseModel):
    """The whole incidents.json file, top to bottom."""
 
    model_config = {"extra": "forbid"}
 
    generated_at: str
    hostname: str
    overall_status: Literal["HEALTHY", "WARNING"]
    system: SystemMetrics
    services: list[Service]