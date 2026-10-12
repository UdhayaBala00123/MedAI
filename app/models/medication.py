from datetime import datetime, timezone

from sqlalchemy import String, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Medication(Base):
    __tablename__ = "medications"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )

    medicine_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False
    )

    dosage: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    dosage_unit: Mapped[str] = mapped_column(
        String(30),
        nullable=False
    )

    instructions: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True
    )

    frequency: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    start_date: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )

    end_date: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True
    )

    active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )