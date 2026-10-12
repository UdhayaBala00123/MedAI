from datetime import datetime

from pydantic import BaseModel, Field


# =========================
# Create Health Metric
# =========================

class HealthMetricCreate(BaseModel):
    metric_type: str = Field(
        ...,
        min_length=1,
        max_length=50
    )

    value: float

    unit: str = Field(
        ...,
        min_length=1,
        max_length=20
    )

    recorded_at: datetime | None = None

    source: str | None = Field(
        default=None,
        max_length=50
    )


# =========================
# Health Metric Response
# =========================

class HealthMetricResponse(BaseModel):
    id: int
    user_id: int
    metric_type: str
    value: float
    unit: str
    recorded_at: datetime
    source: str | None = None

    model_config = {
        "from_attributes": True
    }