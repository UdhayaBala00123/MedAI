# MedAI — AI-Powered Healthcare Assistant

**SwiftUI | FastAPI | PostgreSQL | HealthKit | Groq AI | Docker**

MedAI is an AI-powered healthcare application that combines an iOS mobile app with a Python backend to help users manage health metrics, medical reports, medication reminders, and AI-assisted report analysis.

## Key Features

- **Authentication:** User registration, login, JWT authentication, and Keychain token storage.
- **Health Metrics:** View health measurements and integrate with Apple Health through HealthKit permissions.
- **Medical Reports:** Upload, retrieve, and manage medical reports.
- **AI Report Analysis:** Generate structured summaries of supported PDF reports and images.
- **AI Chat:** Interact with an AI-powered healthcare assistant.
- **Medication Management:** Manage medication information and reminders.
- **REST API:** Connect the iOS app to the backend using authenticated API requests.

## Technology Stack

| Component | Technologies |
|---|---|
| iOS Frontend | Swift, SwiftUI, Xcode |
| Networking | Alamofire, REST APIs |
| Health Integration | Apple HealthKit |
| Backend | Python, FastAPI |
| Database | PostgreSQL |
| ORM | SQLAlchemy |
| Authentication | JWT |
| AI Integration | Groq API |
| Document Processing | pypdf, pytesseract where configured |
| Infrastructure | Docker, Docker Compose |
| Version Control | Git, GitHub |

## System Architecture

```mermaid
flowchart TD
    A[User] --> B[MedAI iOS App]
    B --> C[SwiftUI Views and ViewModels]
    C --> D[API Services]
    D --> E[FastAPI Backend]
    E --> F[Authentication and Business Logic]
    F --> G[(PostgreSQL)]
    F --> H[AI Chat and Report Analysis]
    H --> I[Groq API]
    J[Apple Health] --> K[HealthKit Service]
    K --> D
git clone https://github.com/UdhayaBala00123/MedAI.git
