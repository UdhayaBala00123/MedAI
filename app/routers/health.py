from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.health_metric import HealthMetric
from app.schemas.health_metric import (
    HealthMetricCreate,
    HealthMetricResponse
)
from app.core.dependencies import get_current_user
from app.models.user import User


router = APIRouter(
    prefix="/api/health",
    tags=["Health Metrics"]
)


# =========================
# Create Health Metric
# =========================

@router.post(
    "/metrics",
    response_model=HealthMetricResponse,
    status_code=status.HTTP_201_CREATED
)
def create_health_metric(
    metric_data: HealthMetricCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_metric = HealthMetric(
        user_id=current_user.id,
        metric_type=metric_data.metric_type,
        value=metric_data.value,
        unit=metric_data.unit,
        recorded_at=metric_data.recorded_at,
        source=metric_data.source
    )

    db.add(new_metric)
    db.commit()
    db.refresh(new_metric)

    return new_metric

# =========================
# Get Health Metrics
# =========================

@router.get(
    "/metrics",
    response_model=list[HealthMetricResponse]
)
def get_health_metrics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    metrics = (
        db.query(HealthMetric)
        .filter(HealthMetric.user_id == current_user.id)
        .order_by(HealthMetric.recorded_at.desc())
        .all()
    )

    return metrics

# =========================
# Get Metrics By Type
# =========================

@router.get(
    "/metrics/{metric_type}",
    response_model=list[HealthMetricResponse]
)
def get_metrics_by_type(
    metric_type: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    metrics = (
        db.query(HealthMetric)
        .filter(
            HealthMetric.user_id == current_user.id,
            HealthMetric.metric_type == metric_type
        )
        .order_by(HealthMetric.recorded_at.desc())
        .all()
    )

    return metrics