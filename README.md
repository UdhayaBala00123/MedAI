# MedAI — AI-Powered Healthcare Assistant

**SwiftUI | FastAPI | PostgreSQL | HealthKit | Groq AI | Docker**

MedAI is an AI-powered healthcare application that combines an iOS mobile app with a Python backend to help users manage health metrics, medical reports, medication information, reminders, and AI-assisted report analysis.

The project integrates mobile application development, REST API services, database management, Apple Health integration, and AI-powered document analysis into one healthcare platform.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Backend Setup](#backend-setup)
- [iOS Application Setup](#ios-application-setup)
- [API Endpoints](#api-endpoints)
- [Security](#security)
- [Future Enhancements](#future-enhancements)
- [Disclaimer](#disclaimer)

---

## Project Overview

Healthcare information is often distributed across medical reports, health measurements, medication schedules, and different digital platforms. MedAI aims to provide a centralized mobile experience for managing this information.

The iOS application communicates with a FastAPI backend through REST APIs. The backend manages authentication, health metrics, medical reports, medication-related features, and AI requests, while PostgreSQL provides persistent storage.

The application also integrates with Apple Health through HealthKit, subject to user permissions and data availability.

## Key Features

### 1. User Authentication
- User registration and login.
- Token-based authentication.
- Secure authentication token storage using iOS Keychain.
- Authenticated communication between the iOS application and backend.

### 2. Health Metrics
- Retrieve and display health metrics from the backend.
- Integrate with Apple Health using HealthKit.
- Access supported measurements such as heart rate, blood oxygen, and step count when available and authorized.
- Synchronize supported health measurements with the backend.

### 3. Medical Report Management
- Upload supported medical reports.
- Retrieve and manage report information.
- View report details.
- Request AI-assisted analysis of supported reports.

### 4. AI Medical Report Analysis
- Extract text from supported PDF reports and images.
- Generate structured report summaries using an AI service.
- Display analysis results in the iOS application.

AI-generated summaries may contain errors and should not be treated as a medical diagnosis.

### 5. AI Chat Assistant
- Send healthcare-related questions to the backend.
- Receive AI-generated responses.
- Display responses through the iOS chat interface.

### 6. Medication Management
- Manage medication information.
- Create and manage medication reminders.
- Support reminder notifications where configured.

---

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
| Containerization | Docker, Docker Compose |
| Version Control | Git, GitHub |

---

## System Architecture

```mermaid
flowchart TD
    A[User] --> B[MedAI iOS App]
    B --> C[SwiftUI Views and ViewModels]
    C --> D[API Services]
    D --> E[FastAPI Backend]
    E --> F[Authentication and Business Logic]
    F --> G[(PostgreSQL Database)]
    F --> H[AI Chat and Report Analysis]
    H --> I[Groq API]
    J[Apple Health] --> K[HealthKit Service]
    K --> D
```

### Architecture Overview

1. **iOS Frontend:** Presents the user interface and handles user interactions.
2. **API Services:** Send requests between the mobile application and backend.
3. **FastAPI Backend:** Handles authentication, validation, application logic, and database operations.
4. **PostgreSQL:** Stores application data.
5. **AI Integration:** Supports AI chat and medical report analysis through the configured AI provider.
6. **HealthKit:** Provides access to supported Apple Health data when permission is granted.

---

## Project Structure

```text
MedAI/
├── app/
│   ├── core/
│   ├── models/
│   ├── routers/
│   ├── schemas/
│   └── main.py
├── ios/
│   ├── MedAI.xcodeproj/
│   ├── MedAI/
│   │   ├── App/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── MedAITests/
│   └── MedAIUITests/
├── README.md
├── requirements.txt
└── docker-compose.yml
```

The backend contains the API implementation, while the `ios/` directory contains the Xcode project, SwiftUI application, services, view models, and test targets.

---

## Prerequisites

### Backend Requirements
- Python version compatible with the dependencies in `requirements.txt`.
- Docker Desktop and Docker Compose.
- PostgreSQL.
- A Groq API key for AI features.

### iOS Requirements
- macOS.
- Xcode with a compatible iOS SDK.
- An iOS simulator or compatible physical iPhone.
- Swift Package Manager dependencies resolved through Xcode.

---

## Backend Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/UdhayaBala00123/MedAI.git
cd MedAI
```

### Step 2: Create a Python Virtual Environment

From the directory containing `requirements.txt`:

```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Configure Environment Variables

Create a `.env` file in the directory expected by your backend configuration.

Example configuration:

```env
DATABASE_URL=postgresql://medai:YOUR_DATABASE_PASSWORD@localhost:5432/medai
SECRET_KEY=YOUR_SECRET_KEY
GROQ_API_KEY=YOUR_GROQ_API_KEY
```

These are example variable names. Check the backend settings and Docker Compose configuration for the exact variable names, database credentials, and connection details used by your implementation.

**Do not commit real passwords, API keys, authentication secrets, or `.env` files to GitHub.**

### Step 5: Start PostgreSQL

From the directory containing `docker-compose.yml`:

```bash
docker compose up -d
```

Verify that the database container is running:

```bash
docker ps
```

Ensure the database name, username, password, and port match your backend configuration.

### Step 6: Run the FastAPI Server

Run the server from the directory containing the `app` Python package:

```bash
python -m uvicorn app.main:app --reload
```

The development server commonly runs at:

- **API Base URL:** `http://127.0.0.1:8000`
- **Interactive API Documentation:** `http://127.0.0.1:8000/docs`

The correct working directory depends on where the backend's `app` package is located.

---

## iOS Application Setup

### Step 1: Open the Xcode Project

From the repository root:

```bash
open ios/MedAI.xcodeproj
```

### Step 2: Resolve Dependencies

Open the project in Xcode and allow Swift Package Manager to resolve the configured dependencies, including Alamofire.

### Step 3: Configure the API Base URL

Open:

`ios/MedAI/Services/APIService.swift`

For an iOS simulator running on the same Mac as the backend, the API base URL may be:

```text
http://127.0.0.1:8000
```

For a physical iPhone, use your Mac's reachable local network IP address instead of `127.0.0.1`. Ensure both devices can communicate over the network and the backend listens on an appropriate interface.

For production deployment, configure HTTPS and appropriate network security settings.

### Step 4: Build and Run

1. Select the `MedAI` scheme in Xcode.
2. Choose an iOS simulator or connected iPhone.
3. Configure signing if required.
4. Build and run the application.

### Step 5: Configure HealthKit

HealthKit functionality requires the appropriate Xcode capabilities, usage descriptions, user permissions, and available health data. The availability of measurements depends on the device, data sources, and permissions granted.

---

## API Endpoints

The following endpoints are documented in the project implementation.

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Register a user |
| POST | `/api/auth/login` | Authenticate a user |
| GET | `/api/auth/me` | Retrieve the authenticated user |
| GET | `/api/health/metrics` | Retrieve health metrics |
| GET | `/api/health/metrics/{metric_type}` | Retrieve metrics by type |
| POST | `/api/health/metrics` | Create a health metric |
| POST | `/api/reports/{report_id}/analyze` | Request AI report analysis |
| GET | `/docs` | Open interactive API documentation |

Additional report, medication, reminder, and AI chat endpoints may be available. Use the running FastAPI documentation at `/docs` to inspect the complete endpoint list, request schemas, and authentication requirements.

Protected endpoints require valid authentication credentials.

---

## Security

- Store secrets and credentials in environment variables rather than source code.
- Keep `.env` files out of version control.
- Use iOS Keychain for authentication token storage.
- Authenticate protected API requests and validate user ownership.
- Keep AI provider credentials on the backend.
- Request only the HealthKit permissions required by the application.
- Use HTTPS and secure database credentials in production.
- Avoid exposing a development server directly to the public internet.

---

## Future Enhancements

- Health metric trends and visual dashboards.
- Expanded health data synchronization.
- Medical report history and comparison.
- Improved AI report explanations with references to source content.
- Expanded automated testing and continuous integration.
- Production deployment with monitoring and logging.
- Additional privacy and data-management controls.

---

## Disclaimer

MedAI is a software development project intended for health information management and educational use. AI-generated responses and report summaries may contain errors. The application is not a substitute for professional medical advice, diagnosis, or treatment. Users should consult qualified healthcare professionals for medical decisions.

---

**MedAI — Integrating iOS development, backend engineering, health data, and AI-assisted document analysis.**
