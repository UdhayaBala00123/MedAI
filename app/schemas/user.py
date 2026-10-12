from datetime import datetime

from pydantic import BaseModel, EmailStr


# =========================
# User Registration
# =========================

class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    date_of_birth: datetime | None = None
    gender: str | None = None


# =========================
# User Response
# =========================

class UserResponse(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    date_of_birth: datetime | None = None
    gender: str | None = None

    model_config = {
        "from_attributes": True
    }


# =========================
# User Login
# =========================

class UserLogin(BaseModel):
    email: EmailStr
    password: str


# =========================
# JWT Token Response
# =========================

class TokenResponse(BaseModel):
    access_token: str
    token_type: str