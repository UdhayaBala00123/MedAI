
import os
from pathlib import Path

import httpx
from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

# Load backend/.env
BACKEND_DIR = Path(__file__).resolve().parents[2]
load_dotenv(BACKEND_DIR / ".env")

router = APIRouter(
    prefix="/api/ai",
    tags=["AI Chat"],
)

GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = os.getenv("GROQ_MODEL", "openai/gpt-oss-20b")


SYSTEM_PROMPT = """
You are MedAI, a personal health information assistant.

Use only the supplied health records when answering questions
about the user's recorded measurements.

HEALTH RECORDS:
{health_context}

Rules:
1. Never invent health measurements.
2. If a measurement is unavailable, say so.
3. Distinguish recorded data from general health information.
4. Mention the measurement timestamp when available.
5. Do not claim old measurements are current.
6. Do not diagnose medical conditions.
7. Recommend professional medical care when appropriate.
8. Never reveal another user's health information.
9. Answer clearly and concisely.
"""


class AIChatRequest(BaseModel):
    health_context: str
    user_message: str


def query_groq_api(health_context: str, user_message: str) -> dict:
    api_key = os.getenv("GROQ_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="GROQ_API_KEY is missing from backend/.env",
        )

    payload = {
        "model": GROQ_MODEL,
        "messages": [
            {
                "role": "system",
                "content": SYSTEM_PROMPT.format(
                    health_context=health_context
                ),
            },
            {
                "role": "user",
                "content": user_message,
            },
        ],
        "temperature": 0.2,
    }

    try:
        response = httpx.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json=payload,
            timeout=30.0,
        )
        response.raise_for_status()

        data = response.json()
        return {
            "answer": data["choices"][0]["message"]["content"]
        }

    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=502,
            detail=f"Groq API error: {e.response.text}",
        ) from e

    except httpx.RequestError as e:
        raise HTTPException(
            status_code=502,
            detail=f"Could not connect to Groq: {str(e)}",
        ) from e

    except (KeyError, IndexError, ValueError) as e:
        raise HTTPException(
            status_code=502,
            detail="Invalid response received from Groq API.",
        ) from e


@router.post("/chat")
def chat_with_ai(request: AIChatRequest):
    return query_groq_api(
        health_context=request.health_context,
        user_message=request.user_message,
    )
