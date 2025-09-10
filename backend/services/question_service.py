from typing import List, Dict, Any, Optional
from models.database import SessionLocal
from models.question import QuestionBank, QuestionCreate

class QuestionService:
    def __init__(self):
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