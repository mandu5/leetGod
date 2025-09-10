from sqlalchemy import Column, Integer, String, Text, JSON, DateTime
from sqlalchemy.sql import func
from models.database import Base
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime

class QuestionBank(Base):
    """문제 은행 테이블"""
    __tablename__ = "question_banks"
    
    id = Column(Integer, primary_key=True, index=True)
    subject = Column(String(50), nullable=False)  # 과목 (민법, 형법, 헌법, 상법 등)
    unit = Column(String(100), nullable=False)    # 단원
    difficulty = Column(Integer, nullable=False)   # 난이도 (1-5)
    points = Column(Integer, nullable=False)      # 배점 (3, 4, 5)
    question_type = Column(String(50), nullable=False)  # 문제 유형
    content = Column(Text, nullable=False)        # 문제 내용
    options = Column(JSON)                        # 선택지 (JSON)
    correct_answer = Column(String(10), nullable=False)  # 정답
    explanation = Column(Text)                    # 해설
    tags = Column(JSON)                          # 태그 (JSON)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class QuestionCreate(BaseModel):
    subject: str
    unit: str
    difficulty: int
    points: int
    question_type: str
    content: str
    options: Optional[List[str]] = None
    correct_answer: str
    explanation: Optional[str] = None
    tags: Optional[List[str]] = None

class QuestionResponse(BaseModel):
    id: int
    subject: str
    unit: str
    difficulty: int
    points: int
    question_type: str
    content: str
    options: Optional[List[str]] = None
    correct_answer: str
    explanation: Optional[str] = None
    tags: Optional[List[str]] = None
    created_at: datetime

    class Config:
        from_attributes = True

class DiagnosticQuestion(BaseModel):
    id: int
    content: str
    options: List[str]
    points: int
    unit: str

class DailyTestQuestion(BaseModel):
    id: int
    content: str
    options: List[str]
    points: int
    unit: str

class QuestionService:
    def __init__(self):
        from models.database import SessionLocal
        self.db = SessionLocal()
    
    def create_question(self, question_data: QuestionCreate) -> QuestionBank:
        """새로운 문제 생성"""
        db_question = QuestionBank(**question_data.dict())
        self.db.add(db_question)
        self.db.commit()
        self.db.refresh(db_question)
        return db_question
    
    def get_question_by_id(self, question_id: int) -> Optional[QuestionBank]:
        """ID로 문제 조회"""
        return self.db.query(QuestionBank).filter(QuestionBank.id == question_id).first()
    
    def get_questions_by_criteria(
        self, 
        subject: Optional[str] = None,
        unit: Optional[str] = None,
        difficulty: Optional[int] = None,
        points: Optional[int] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """조건에 맞는 문제 조회"""
        query = self.db.query(QuestionBank)
        
        if subject:
            query = query.filter(QuestionBank.subject == subject)
        if unit:
            query = query.filter(QuestionBank.unit == unit)
        if difficulty:
            query = query.filter(QuestionBank.difficulty == difficulty)
        if points:
            query = query.filter(QuestionBank.points == points)
        
        questions = query.limit(limit).all()
        
        return [
            {
                "id": q.id,
                "content": q.content,
                "options": q.options or [],
                "correct_answer": q.correct_answer,
                "explanation": q.explanation,
                "unit": q.unit,
                "difficulty": q.difficulty,
                "points": q.points,
                "tags": q.tags or []
            }
            for q in questions
        ] 