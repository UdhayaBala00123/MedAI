from datetime import datetime, timezone

from sqlalchemy import String, DateTime, Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class ReportResult(Base):
    __tablename__ = "report_results"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True
    )

    report_id: Mapped[int] = mapped_column(
        ForeignKey("medical_reports.id"),
        nullable=False,
        index=True
    )

    test_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    value: Mapped[float] = mapped_column(
        Float,
        nullable=False
    )

    unit: Mapped[str] = mapped_column(
        String(30),
        nullable=False
    )

    reference_range: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True
    )

    status: Mapped[str | None] = mapped_column(
        String(30),
        nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )