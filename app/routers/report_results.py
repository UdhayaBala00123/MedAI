from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status
)

from sqlalchemy.orm import Session

from app.database import get_db
from app.models.report_result import ReportResult
from app.models.medical_report import MedicalReport
from app.models.user import User
from app.schemas.report_result import (
    ReportResultCreate,
    ReportResultResponse
)
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/api/report-results",
    tags=["Report Results"]
)


@router.post(
    "",
    response_model=ReportResultResponse,
    status_code=status.HTTP_201_CREATED
)
def create_report_result(
    result_data: ReportResultCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    report = (
        db.query(MedicalReport)
        .filter(
            MedicalReport.id == result_data.report_id,
            MedicalReport.user_id == current_user.id
        )
        .first()
    )

    if report is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medical report not found"
        )

    new_result = ReportResult(
        report_id=result_data.report_id,
        test_name=result_data.test_name,
        value=result_data.value,
        unit=result_data.unit,
        reference_range=result_data.reference_range,
        status=result_data.status
    )

    db.add(new_result)
    db.commit()
    db.refresh(new_result)

    return new_result

@router.get(
    "/{report_id}",
    response_model=list[ReportResultResponse]
)
def get_report_results(
    report_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    report = (
        db.query(MedicalReport)
        .filter(
            MedicalReport.id == report_id,
            MedicalReport.user_id == current_user.id
        )
        .first()
    )

    if report is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medical report not found"
        )

    results = (
        db.query(ReportResult)
        .filter(
            ReportResult.report_id == report_id
        )
        .order_by(
            ReportResult.created_at.asc()
        )
        .all()
    )

    return results