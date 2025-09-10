from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from models.database import Base
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class User(Base):
    """사용자 테이블"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(100), nullable=False)
    grade = Column(String(20), nullable=False)  # "1등급", "2등급", etc.
    target_grade = Column(String(20), nullable=False)  # "1등급", "2등급", etc.
    study_time = Column(Integer, nullable=False)  # 분 단위
    learning_style = Column(String(50), nullable=False)  # "concept_first", "problem_focused", "mixed"
    diagnostic_completed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    grade: str  # "1등급", "2등급", etc.
    target_grade: str  # "1등급", "2등급", etc.
    study_time: int  # 분 단위
    learning_style: str  # "concept_first", "problem_focused", "mixed"

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    grade: str
    target_grade: str
    study_time: int
    learning_style: str
    diagnostic_completed: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    grade: Optional[str] = None
    target_grade: Optional[str] = None
    study_time: Optional[int] = None
    learning_style: Optional[str] = None 