from datetime import datetime

from pydantic import BaseModel, Field


class MedicalReportCreate(BaseModel):
    title: str = Field(
        ...,
        min_length=1,
        max_length=200
    )

    report_type: str = Field(
        ...,
        min_length=1,
        max_length=50
    )

    report_date: datetime | None = None


class MedicalReportResponse(BaseModel):
    id: int
    user_id: int
    title: str
    report_type: str
    file_url: str
    report_date: datetime | None = None
    uploaded_at: datetime
    status: str

    model_config = {
        "from_attributes": True
    }