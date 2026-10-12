from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.medication import Medication
from app.models.medication_reminder import MedicationReminder
from app.models.user import User
from app.schemas.medication_reminder import (
    MedicationReminderCreate,
    MedicationReminderResponse
)
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/api/medication-reminders",
    tags=["Medication Reminders"]
)


@router.post(
    "",
    response_model=MedicationReminderResponse,
    status_code=status.HTTP_201_CREATED
)
def create_reminder(
    reminder_data: MedicationReminderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Make sure the medication belongs to the logged-in user
    medication = (
        db.query(Medication)
        .filter(
            Medication.id == reminder_data.medication_id,
            Medication.user_id == current_user.id
        )
        .first()
    )

    if medication is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication not found"
        )

    new_reminder = MedicationReminder(
        medication_id=reminder_data.medication_id,
        reminder_time=reminder_data.reminder_time,
        days_of_week=reminder_data.days_of_week
    )

    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)

    return new_reminder


@router.get(
    "/medication/{medication_id}",
    response_model=list[MedicationReminderResponse]
)
def get_medication_reminders(
    medication_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    medication = (
        db.query(Medication)
        .filter(
            Medication.id == medication_id,
            Medication.user_id == current_user.id
        )
        .first()
    )

    if medication is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication not found"
        )

    reminders = (
        db.query(MedicationReminder)
        .filter(
            MedicationReminder.medication_id == medication_id
        )
        .order_by(MedicationReminder.reminder_time.asc())
        .all()
    )

    return reminders


@router.get(
    "/{reminder_id}",
    response_model=MedicationReminderResponse
)
def get_reminder(
    reminder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    reminder = (
        db.query(MedicationReminder)
        .join(
            Medication,
            Medication.id == MedicationReminder.medication_id
        )
        .filter(
            MedicationReminder.id == reminder_id,
            Medication.user_id == current_user.id
        )
        .first()
    )

    if reminder is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication reminder not found"
        )

    return reminder


@router.delete(
    "/{reminder_id}",
    status_code=status.HTTP_204_NO_CONTENT
)
def delete_reminder(
    reminder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    reminder = (
        db.query(MedicationReminder)
        .join(
            Medication,
            Medication.id == MedicationReminder.medication_id
        )
        .filter(
            MedicationReminder.id == reminder_id,
            Medication.user_id == current_user.id
        )
        .first()
    )

    if reminder is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication reminder not found"
        )

    db.delete(reminder)
    db.commit()

    return None