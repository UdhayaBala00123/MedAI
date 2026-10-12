from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.medical_report import MedicalReport
from app.models.report_result import ReportResult
from app.models.user import User
from app.core.dependencies import get_current_user
from app.services.report_extractor import extract_text_from_pdf
from app.services.lab_parser import parse_lab_results
from app.services.lab_reference import evaluate_reference_range


router = APIRouter(
    prefix="/api/reports",
    tags=["Report Extraction"]
)


# =========================================================
# EXTRACT TEXT FROM PDF
# =========================================================

@router.post("/{report_id}/extract-text")
def extract_report_text(
    report_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Find report belonging to current user
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

    # Only PDF is currently supported
    if not report.file_url.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Text extraction currently supports PDF reports only"
        )

    # Extract text
    try:
        text = extract_text_from_pdf(report.file_url)

    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report file not found on server"
        )

    return {
        "report_id": report.id,
        "title": report.title,
        "text": text
    }


# =========================================================
# PROCESS MEDICAL REPORT
# =========================================================

@router.post("/{report_id}/process")
def process_medical_report(
    report_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # ---------------------------------------------------------
    # 1. Find the report
    # ---------------------------------------------------------

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

    # ---------------------------------------------------------
    # 2. Check file type
    # ---------------------------------------------------------

    if not report.file_url.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Processing currently supports PDF reports only"
        )

    # ---------------------------------------------------------
    # 3. Prevent duplicate processing
    # ---------------------------------------------------------

    existing_results = (
        db.query(ReportResult)
        .filter(
            ReportResult.report_id == report.id
        )
        .order_by(
            ReportResult.created_at.asc()
        )
        .all()
    )

    if existing_results:
        return {
            "report_id": report.id,
            "title": report.title,
            "results": [
                {
                    "id": result.id,
                    "test_name": result.test_name,
                    "value": result.value,
                    "unit": result.unit,
                    "reference_range": result.reference_range,
                    "status": result.status
                }
                for result in existing_results
            ]
        }

    # ---------------------------------------------------------
    # 4. Extract text from PDF
    # ---------------------------------------------------------

    try:
        text = extract_text_from_pdf(report.file_url)

    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report file not found on server"
        )

    # ---------------------------------------------------------
    # 5. Parse laboratory results
    # ---------------------------------------------------------

    parsed_results = parse_lab_results(text)

    if not parsed_results:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="No supported lab results could be extracted"
        )

    # ---------------------------------------------------------
    # 6. Save extracted results
    # ---------------------------------------------------------

    saved_results = []

    for result in parsed_results:

        # Reference range extracted directly from the report
        reference_range = result.get("reference_range")

        # Evaluate value against report-specific range
        result_status = evaluate_reference_range(
            result["value"],
            reference_range
        )

        # Create database record
        new_result = ReportResult(
            report_id=report.id,
            test_name=result["test_name"],
            value=result["value"],
            unit=result["unit"],
            reference_range=reference_range,
            status=result_status
        )

        db.add(new_result)
        saved_results.append(new_result)

    # ---------------------------------------------------------
    # 7. Commit transaction
    # ---------------------------------------------------------

    db.commit()

    # ---------------------------------------------------------
    # 8. Refresh database records
    # ---------------------------------------------------------

    for result in saved_results:
        db.refresh(result)

    # ---------------------------------------------------------
    # 9. Return processed results
    # ---------------------------------------------------------

    return {
        "report_id": report.id,
        "title": report.title,
        "results": [
            {
                "id": result.id,
                "test_name": result.test_name,
                "value": result.value,
                "unit": result.unit,
                "reference_range": result.reference_range,
                "status": result.status
            }
            for result in saved_results
        ]
    }