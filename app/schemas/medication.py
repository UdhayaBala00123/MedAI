from datetime import datetime

from pydantic import BaseModel, Field


class MedicationCreate(BaseModel):
    medicine_name: str = Field(
        ...,
        min_length=1,
        max_length=150
    )

    dosage: str = Field(
        ...,
        min_length=1,
        max_length=50
    )

    dosage_unit: str = Field(
        ...,
        min_length=1,
        max_length=30
    )

    instructions: str | None = Field(
        default=None,
        max_length=255
    )

    frequency: str = Field(
        ...,
        min_length=1,
        max_length=50
    )

    start_date: datetime

    end_date: datetime | None = None


class MedicationResponse(BaseModel):
    id: int
    user_id: int
    medicine_name: str
    dosage: str
    dosage_unit: str
    instructions: str | None = None
    frequency: str
    start_date: datetime
    end_date: datetime | None = None
    active: bool
    created_at: datetime

    model_config = {
        "from_attributes": True
    }