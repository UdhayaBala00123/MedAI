
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI

# Load environment variables before importing application modules
BACKEND_DIR = Path(__file__).resolve().parents[1]
load_dotenv(BACKEND_DIR / ".env")

from app.database import Base, engine
from app.models.user import User

from app.routers.auth import router as auth_router
from app.routers.health import router as health_router
from app.routers.reports import router as reports_router
from app.routers.report_results import router as report_results_router
from app.routers.report_extraction import router as report_extraction_router
from app.routers.report_summary import router as report_summary_router
from app.routers.medications import router as medications_router
from app.routers.medication_reminders import router as medication_reminders_router

# AI routers
from app.routers.ai import router as ai_router
from app.routers.ai_reports import router as ai_reports_router


# Create database tables
Base.metadata.create_all(bind=engine)


# Initialize FastAPI application
app = FastAPI(
    title="MedAI API",
    description="AI-powered personal health companion backend",
    version="1.0.0",
)


# Register application routers
app.include_router(auth_router)
app.include_router(health_router)
app.include_router(reports_router)
app.include_router(report_results_router)
app.include_router(report_extraction_router)
app.include_router(report_summary_router)
app.include_router(medications_router)
app.include_router(medication_reminders_router)

# Register AI endpoints
app.include_router(ai_router)
app.include_router(ai_reports_router)


@app.get("/")
def root():
    return {
        "message": "Welcome to MedAI API",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
    }
