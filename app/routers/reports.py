from fastapi import (
    APIRouter,
    Depends,
    UploadFile,
    File,
    Form,
    HTTPException,
    status
)

from sqlalchemy.orm import Session

from pathlib import Path
from datetime import datetime

from app.database import get_db
from app.models.medical_report import MedicalReport
from app.models.user import User
from app.schemas.medical_report import MedicalReportResponse
from app.core.dependencies import get_current_user


router = APIRouter(
    prefix="/api/reports",
    tags=["Medical Reports"]
)


UPLOAD_DIR = Path("uploads/reports")
UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)


@router.post(
    "/upload",
    response_model=MedicalReportResponse,
    status_code=status.HTTP_201_CREATED
)
async def upload_medical_report(
    title: str = Form(...),
    report_type: str = Form(...),
    report_date: datetime | None = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    allowed_extensions = {
        ".pdf",
        ".jpg",
        ".jpeg",
        ".png"
    }

    file_extension = Path(file.filename).suffix.lower()

    if file_extension not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF, JPG, JPEG and PNG files are allowed"
        )

    user_upload_dir = UPLOAD_DIR / str(current_user.id)

    user_upload_dir.mkdir(
        parents=True,
        exist_ok=True
    )

    filename = (
        f"{datetime.utcnow().strftime('%Y%m%d%H%M%S')}_"
        f"{file.filename}"
    )

    file_path = user_upload_dir / filename

    file_content = await file.read()

    with open(file_path, "wb") as buffer:
        buffer.write(file_content)

    new_report = MedicalReport(
        user_id=current_user.id,
        title=title,
        report_type=report_type,
        file_url=str(file_path),
        report_date=report_date
    )

    db.add(new_report)
    db.commit()
    db.refresh(new_report)

    return new_report


@router.get(
    "",
    response_model=list[MedicalReportResponse]
)
def get_medical_reports(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    reports = (
        db.query(MedicalReport)
        .filter(
            MedicalReport.user_id == current_user.id
        )
        .order_by(
            MedicalReport.uploaded_at.desc()
        )
        .all()
    )

    return reports

@router.get(
    "/{report_id}",
    response_model=MedicalReportResponse
)
def get_medical_report(
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

    return report

@router.delete(
    "/{report_id}",
    status_code=status.HTTP_204_NO_CONTENT
)
def delete_medical_report(
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

    file_path = Path(report.file_url)

    if file_path.exists():
        file_path.unlink()

    db.delete(report)
    db.commit()

    return None