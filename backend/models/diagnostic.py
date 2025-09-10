from sqlalchemy import Column, Integer, String, Float, DateTime, Text, JSON
from sqlalchemy.sql import func
from models.database import Base

class DiagnosticResult(Base):
    __tablename__ = "diagnostic_results"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    total_score = Column(Integer)
    total_points = Column(Integer)
    accuracy = Column(Float)
    estimated_grade = Column(String(20))
    strong_units = Column(JSON)  # 강점 단원 리스트
    weak_units = Column(JSON)    # 약점 단원 리스트
    unit_scores = Column(JSON)   # 단원별 점수
    wrong_questions = Column(JSON)  # 틀린 문제 리스트
    completed_at = Column(DateTime, default=func.now())
    
    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "total_score": self.total_score,
            "total_points": self.total_points,
            "accuracy": self.accuracy,
            "estimated_grade": self.estimated_grade,
            "strong_units": self.strong_units,
            "weak_units": self.weak_units,
            "unit_scores": self.unit_scores,
            "wrong_questions": self.wrong_questions,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None
        } 