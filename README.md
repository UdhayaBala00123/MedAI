# MedAI — AI-Powered Healthcare Assistant Backend

**FastAPI | PostgreSQL | SQLAlchemy | Groq AI | JWT Authentication**

## 1. Project Overview

MedAI is an AI-assisted healthcare application designed to help users access and understand their health information through a mobile interface. The backend provides secure APIs for user authentication, health metric management, medication reminders, AI-powered healthcare conversations, and medical report analysis.

Built using **FastAPI and PostgreSQL**, the backend connects the MedAI iOS application with persistent data storage and AI services. It is designed with modular routing, authenticated endpoints, and structured request and response models.

## 2. Problem Statement

Healthcare information is often distributed across medical reports, health measurements, medication schedules, and different digital platforms. Users may find it difficult to manage this information in one place or understand the meaning of medical report results.

Traditional healthcare applications may also lack an integrated interface for asking health-related questions and receiving simplified explanations of medical documents.

Therefore, a secure and extensible backend is required to centralize health information, support mobile application communication, and provide AI-assisted explanations while protecting user data.

## 3. Proposed Solution

MedAI addresses these challenges through a RESTful backend that integrates health data management, authentication, and AI capabilities.

The backend provides the following functionality:

- **User authentication:** Registration, login, and authenticated access using JWT-based authentication.
- **Health metric management:** Store and retrieve measurements such as heart rate, SpO₂, and step count, including timestamps and data sources.
- **AI healthcare chat:** Connect user questions to a Groq-powered language model to generate understandable responses.
- **Medical report analysis:** Extract text from supported medical report files and generate structured, plain-language summaries using AI.
- **Medication reminders:** Support medication reminder functionality through dedicated API routes.
- **Persistent storage:** Store user accounts, health metrics, and medical report metadata in PostgreSQL.

AI-generated responses are informational and do not replace professional medical advice.

## 4. Project Objectives

1. Develop a reliable REST API for the MedAI iOS application.
2. Secure user-specific information using authentication and authorization.
3. Store health measurements and medical report metadata in a relational database.
4. Integrate a language model for AI-assisted conversations and report explanations.
5. Design modular API routes that are easy to maintain and extend.
6. Support future integration with Apple HealthKit and compatible health devices.

## 5. System Architecture

The backend follows a client-server architecture.

```text
┌──────────────────────────┐
│   MedAI iOS Application  │
│      SwiftUI Frontend    │
└────────────┬─────────────┘
             │ HTTPS / REST API
             ▼
┌──────────────────────────┐
│       FastAPI Backend    │
├──────────────────────────┤
│ Authentication & JWT     │
│ Health Metrics           │
│ Medication Reminders     │
│ AI Chat                  │
│ Medical Report Analysis  │
└───────┬──────────┬───────┘
        │          │
        ▼          ▼
┌──────────────┐ ┌────────────────┐
│ PostgreSQL   │ │ Groq AI API    │
│ Database     │ │ Language Model │
└──────────────┘ └────────────────┘
```

### Architecture Components

- **Frontend:** SwiftUI-based iOS application.
- **API layer:** FastAPI endpoints receive requests and return structured responses.
- **Authentication layer:** Validates access tokens and identifies the current user.
- **Database layer:** SQLAlchemy communicates with PostgreSQL.
- **AI integration:** Groq API processes supported chat and medical report analysis requests.
- **Document processing:** PDF text extraction and OCR for supported image formats.

## 6. Key Features

### 6.1 Authentication and Authorization

The backend supports user registration and login. Protected endpoints use JWT authentication to associate requests with the authenticated user.

### 6.2 Health Metrics Management

The application can store and retrieve health measurements with their values, units, timestamps, and source information.

Example metrics include:

- Heart rate — beats per minute (bpm)
- Blood oxygen saturation — percentage (%)
- Steps — step count

The backend supports API-based health metric storage. Actual real-time measurements depend on an integrated source, such as Apple HealthKit or a compatible device.

### 6.3 AI-Powered Healthcare Chat

The AI chat module connects the application to a Groq-hosted language model. It accepts user questions and returns generated responses intended to explain health-related topics in accessible language.

### 6.4 AI Medical Report Analysis

The medical report analysis module retrieves an authorized user's report, extracts available text, and submits relevant content for AI-assisted explanation.

The output can include:

- Report overview
- Key findings
- Test results and stated reference ranges
- Plain-language explanations
- Important notes and medical disclaimers

The quality of the analysis depends on the source document and the AI model. AI-generated interpretations should be reviewed by a qualified healthcare professional.

### 6.5 Medication Reminders

Dedicated medication reminder routes support the backend functionality for managing medication-related reminder information.

### 6.6 Database Management

PostgreSQL provides persistent storage for application data. SQLAlchemy models and schemas help define database records and validate API input and output.

## 7. Technology Stack

| Technology | Purpose |
|---|---|
| Python | Backend programming language |
| FastAPI | REST API development |
| PostgreSQL | Relational database |
| SQLAlchemy | ORM and database operations |
| Pydantic | Request and response validation |
| JWT | Authentication |
| Groq API | AI-generated responses and report explanations |
| pypdf | PDF text extraction |
| Tesseract OCR | Text recognition from supported images |
| Docker | Local PostgreSQL containerization |
| SwiftUI | iOS application interface |
| Git and GitHub | Version control and source-code hosting |

## 8. Project Structure

```text
backend/
├── app/
│   ├── main.py
│   ├── core/
│   │   ├── dependencies.py
│   │   └── security.py
│   ├── models/
│   │   ├── user.py
│   │   ├── health_metric.py
│   │   └── medical_report.py
│   ├── routers/
│   │   ├── ai.py
│   │   ├── ai_reports.py
│   │   ├── health.py
│   │   ├── medication_reminders.py
│   │   └── reports.py
│   └── schemas/
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

*The structure above illustrates the main backend modules; exact filenames may vary with the current implementation.*

## 9. Installation and Setup

### Prerequisites

- Python 3.11 or another version supported by the project's dependencies
- PostgreSQL, locally installed or running through Docker
- Git
- A Groq API key for AI functionality

### Step 1: Clone the repository

```bash
git clone https://github.com/UdhayaBala00123/MedAI.git
cd MedAI/backend
```

### Step 2: Create a virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Configure environment variables

Create a local `.env` file using `.env.example` as a template. Configure the database connection, JWT settings, and Groq API credentials using the variable names expected by the application.

**Security:** Never commit the real `.env` file, API keys, database passwords, or JWT secrets to GitHub.

### Step 5: Start PostgreSQL

Start your configured PostgreSQL service or Docker container and verify that the database connection settings are correct.

### Step 6: Run the backend

```bash
python -m uvicorn app.main:app --reload
```

The local development server should be available at:

`http://127.0.0.1:8000`

### Step 7: Explore the API

Open the interactive Swagger documentation:

`http://127.0.0.1:8000/docs`

Use Swagger to inspect available endpoints and test authenticated requests.

## 10. Testing and Validation

The backend can be tested using Swagger UI or an API client.

Recommended test cases include:

- Registering a new user and logging in.
- Accessing protected endpoints with a valid token.
- Confirming that users can access only their own health metrics and reports.
- Creating and retrieving health metric records.
- Uploading a supported medical report and verifying text extraction.
- Testing AI chat and report analysis with valid and invalid inputs.
- Confirming that missing credentials and unauthorized access are rejected.

## 11. Security and Privacy Considerations

MedAI processes sensitive health-related information. The backend should therefore follow these principles:

- Protect private endpoints with authentication and authorization.
- Keep API keys and secrets in environment variables.
- Validate request data and restrict uploaded file types and sizes.
- Prevent users from accessing other users' reports or measurements.
- Avoid logging passwords, access tokens, or unnecessary medical information.
- Use HTTPS in deployed environments.
- Treat AI-generated content as informational, not as a medical diagnosis.

## 12. Future Enhancements

Potential future improvements include:

- Automatic HealthKit synchronization and background health updates.
- Duplicate detection and incremental synchronization of health measurements.
- More robust OCR support for scanned PDF reports.
- Structured AI analysis responses for easier presentation in SwiftUI.
- Automated API tests and continuous integration.
- Production deployment with HTTPS, monitoring, and secure database management.

These are proposed enhancements and should not be considered implemented until they are developed and tested.

## 13. Conclusion

MedAI provides a modular backend foundation for an AI-assisted healthcare application. By combining FastAPI, PostgreSQL, JWT authentication, and Groq-powered AI features, the system supports health metric management, medical report explanations, medication-related functionality, and communication with a SwiftUI mobile application.

The project demonstrates how backend API development, database management, authentication, document processing, and generative AI can be integrated into a healthcare-oriented software system.

With further validation, secure deployment, and reliable integration with health data sources, MedAI can be extended into a more comprehensive personal health information platform.

---

**Project:** MedAI — AI-Powered Healthcare Assistant  
**Backend:** FastAPI and PostgreSQL  
**AI Integration:** Groq API  
**Frontend:** SwiftUI for iOS  
**Repository:** [GitHub — UdhayaBala00123/MedAI](https://github.com/UdhayaBala00123/MedAI)