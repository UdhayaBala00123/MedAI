from datetime import datetime, time

from pydantic import BaseModel


class MedicationReminderCreate(BaseModel):
    medication_id: int
    reminder_time: time
    days_of_week: str


class MedicationReminderResponse(BaseModel):
    id: int
    medication_id: int
    reminder_time: time
    days_of_week: str
    active: bool
    created_at: datetime

    model_config = {
        "from_attributes": True
    }