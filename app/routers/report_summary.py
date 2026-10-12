from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.medical_report import MedicalReport
from app.models.report_result import ReportResult
from app.models.user import User
from app.core.dependencies import get_current_user
from app.schemas.report_summary import ReportSummaryResponse
from app.services.report_summary import build_report_summary


router = APIRouter(
    prefix="/api/reports",
    tags=["Report Summary"]
)


@router.get(
    "/{report_id}/summary",
    response_model=ReportSummaryResponse
)
def get_report_summary(
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
        .filter(ReportResult.report_id == report_id)
        .order_by(ReportResult.created_at.asc())
        .all()
    )

    if not results:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No processed results found for this report"
        )

    return build_report_summary(
        report_id=report.id,
        title=report.title,
        results=results
    )