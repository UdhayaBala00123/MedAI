from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.medication import Medication
from app.models.user import User
from app.schemas.medication import MedicationCreate, MedicationResponse
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/api/medications",
    tags=["Medications"]
)


@router.post(
    "",
    response_model=MedicationResponse,
    status_code=status.HTTP_201_CREATED
)
def create_medication(
    medication_data: MedicationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_medication = Medication(
        user_id=current_user.id,
        medicine_name=medication_data.medicine_name,
        dosage=medication_data.dosage,
        dosage_unit=medication_data.dosage_unit,
        instructions=medication_data.instructions,
        frequency=medication_data.frequency,
        start_date=medication_data.start_date,
        end_date=medication_data.end_date
    )

    db.add(new_medication)
    db.commit()
    db.refresh(new_medication)

    return new_medication


@router.get(
    "",
    response_model=list[MedicationResponse]
)
def get_medications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    medications = (
        db.query(Medication)
        .filter(Medication.user_id == current_user.id)
        .order_by(Medication.created_at.desc())
        .all()
    )

    return medications


@router.get(
    "/{medication_id}",
    response_model=MedicationResponse
)
def get_medication(
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

    return medication


@router.put(
    "/{medication_id}",
    response_model=MedicationResponse
)
def update_medication(
    medication_id: int,
    medication_data: MedicationCreate,
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

    medication.medicine_name = medication_data.medicine_name
    medication.dosage = medication_data.dosage
    medication.dosage_unit = medication_data.dosage_unit
    medication.instructions = medication_data.instructions
    medication.frequency = medication_data.frequency
    medication.start_date = medication_data.start_date
    medication.end_date = medication_data.end_date

    db.commit()
    db.refresh(medication)

    return medication


@router.delete(
    "/{medication_id}",
    status_code=status.HTTP_204_NO_CONTENT
)
def delete_medication(
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

    db.delete(medication)
    db.commit()

    return None