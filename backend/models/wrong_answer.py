"""
오답 노트 관련 데이터베이스 모델

이 모듈은 사용자의 틀린 문제들을 관리하고 복습할 수 있도록 하는
오답 노트 시스템의 데이터 모델을 정의합니다.
"""

from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List
from .database import Base


class WrongAnswer(Base):
    """오답 노트 테이블
    
    사용자가 틀린 문제들을 저장하고 관리하는 테이블입니다.
    진단 평가와 일일 모의고사에서 틀린 문제들을 자동으로 수집합니다.
    """
    __tablename__ = "wrong_answers"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    question_id = Column(Integer, nullable=False)  # 문제 ID
    question_content = Column(Text, nullable=False)  # 문제 내용
    user_answer = Column(String(10), nullable=False)  # 사용자 답안
    correct_answer = Column(String(10), nullable=False)  # 정답
    explanation = Column(Text)  # 해설
    unit = Column(String(100))  # 단원 (예: "언어이해-인식론")
    subject = Column(String(50))  # 과목 (예: "언어이해")
    topic = Column(String(100))  # 주제 (예: "인식론")
    difficulty = Column(Float, default=3.0)  # 난이도 (1.0-5.0)
    points = Column(Integer, default=3)  # 배점
    source_type = Column(String(20), default="daily_test")  # 출처 (diagnostic, daily_test)
    source_id = Column(Integer)  # 출처 ID (진단평가 ID 또는 일일모의고사 ID)
    
    # 복습 관련 필드
    review_count = Column(Integer, default=0)  # 복습 횟수
    last_reviewed_at = Column(DateTime(timezone=True))  # 마지막 복습 시간
    mastered = Column(Boolean, default=False)  # 마스터 여부
    mastered_at = Column(DateTime(timezone=True))  # 마스터 달성 시간
    
    # 메타데이터
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 관계 설정
    user = relationship("User", back_populates="wrong_answers")


class WrongAnswerReview(Base):
    """오답 노트 복습 기록 테이블
    
    사용자가 오답 노트의 문제를 다시 풀어본 기록을 저장합니다.
    """
    __tablename__ = "wrong_answer_reviews"
    
    id = Column(Integer, primary_key=True, index=True)
    wrong_answer_id = Column(Integer, ForeignKey("wrong_answers.id"), nullable=False)
    user_answer = Column(String(10), nullable=False)  # 복습 시 사용자 답안
    is_correct = Column(Boolean, nullable=False)  # 복습 시 정답 여부
    time_taken = Column(Integer)  # 소요 시간 (초)
    confidence_level = Column(Integer)  # 확신도 (1-5)
    notes = Column(Text)  # 사용자 메모
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 관계 설정
    wrong_answer = relationship("WrongAnswer")


# Pydantic 모델들
class WrongAnswerCreate(BaseModel):
    """오답 노트 생성용 모델"""
    question_id: int
    question_content: str
    user_answer: str
    correct_answer: str
    explanation: Optional[str] = None
    unit: Optional[str] = None
    subject: Optional[str] = None
    topic: Optional[str] = None
    difficulty: Optional[float] = 3.0
    points: Optional[int] = 3
    source_type: str = "daily_test"
    source_id: Optional[int] = None


class WrongAnswerResponse(BaseModel):
    """오답 노트 응답용 모델"""
    id: int
    question_id: int
    question_content: str
    user_answer: str
    correct_answer: str
    explanation: Optional[str]
    unit: Optional[str]
    subject: Optional[str]
    topic: Optional[str]
    difficulty: Optional[float]
    points: Optional[int]
    source_type: str
    review_count: int
    last_reviewed_at: Optional[datetime]
    mastered: bool
    mastered_at: Optional[datetime]
    created_at: datetime
    
    class Config:
        from_attributes = True


class WrongAnswerReviewCreate(BaseModel):
    """오답 복습 기록 생성용 모델"""
    user_answer: str
    is_correct: bool
    time_taken: Optional[int] = None
    confidence_level: Optional[int] = None
    notes: Optional[str] = None


class WrongAnswerReviewResponse(BaseModel):
    """오답 복습 기록 응답용 모델"""
    id: int
    user_answer: str
    is_correct: bool
    time_taken: Optional[int]
    confidence_level: Optional[int]
    notes: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


class WrongAnswerFilter(BaseModel):
    """오답 노트 필터링용 모델"""
    subject: Optional[str] = None
    unit: Optional[str] = None
    difficulty_min: Optional[float] = None
    difficulty_max: Optional[float] = None
    mastered: Optional[bool] = None
    source_type: Optional[str] = None
    limit: Optional[int] = 20
    offset: Optional[int] = 0


class WrongAnswerStats(BaseModel):
    """오답 노트 통계용 모델"""
    total_count: int
    mastered_count: int
    review_needed_count: int
    by_subject: dict
    by_unit: dict
    by_difficulty: dict
    recent_reviews: List[WrongAnswerReviewResponse]
