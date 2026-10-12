from datetime import datetime

from pydantic import BaseModel, Field


class ReportResultCreate(BaseModel):
    report_id: int

    test_name: str = Field(
        ...,
        min_length=1,
        max_length=100
    )

    value: float

    unit: str = Field(
        ...,
        min_length=1,
        max_length=30
    )

    reference_range: str | None = Field(
        default=None,
        max_length=100
    )

    status: str | None = Field(
        default=None,
        max_length=30
    )


class ReportResultResponse(BaseModel):
    id: int
    report_id: int
    test_name: str
    value: float
    unit: str
    reference_range: str | None = None
    status: str | None = None
    created_at: datetime

    model_config = {
        "from_attributes": True
    }