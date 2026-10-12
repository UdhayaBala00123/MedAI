from datetime import datetime, timezone

from sqlalchemy import String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class MedicalReport(Base):
    __tablename__ = "medical_reports"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )

    title: Mapped[str] = mapped_column(
        String(200),
        nullable=False
    )

    report_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    file_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    report_date: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True
    )

    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="uploaded",
        nullable=False
    )