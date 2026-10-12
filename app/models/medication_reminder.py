from datetime import datetime, time

from sqlalchemy import String, DateTime, Boolean, ForeignKey, Time
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class MedicationReminder(Base):
    __tablename__ = "medication_reminders"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True
    )

    medication_id: Mapped[int] = mapped_column(
        ForeignKey("medications.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )

    reminder_time: Mapped[time] = mapped_column(
        Time,
        nullable=False
    )

    days_of_week: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )