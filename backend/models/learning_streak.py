"""
학습 스트릭 관련 데이터베이스 모델

사용자의 연속 학습 일수와 학습 습관을 추적하는 모델입니다.
"""

from sqlalchemy import Column, Integer, String, DateTime, Boolean, Date, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional, List
from .database import Base


class LearningStreak(Base):
    """학습 스트릭 테이블
    
    사용자의 연속 학습 일수를 추적합니다.
    """
    __tablename__ = "learning_streaks"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    current_streak = Column(Integer, default=0)  # 현재 연속 일수
    longest_streak = Column(Integer, default=0)  # 최장 연속 일수
    last_activity_date = Column(Date)  # 마지막 활동 날짜
    total_study_days = Column(Integer, default=0)  # 총 학습 일수
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 관계 설정
    user = relationship("User", back_populates="learning_streak")
    daily_activities = relationship("DailyActivity", back_populates="learning_streak")


class DailyActivity(Base):
    """일일 학습 활동 테이블
    
    사용자의 일일 학습 활동을 기록합니다.
    """
    __tablename__ = "daily_activities"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    learning_streak_id = Column(Integer, ForeignKey("learning_streaks.id"), nullable=False)
    activity_date = Column(Date, nullable=False)
    
    # 활동 종류별 카운트
    diagnostic_completed = Column(Boolean, default=False)
    daily_tests_completed = Column(Integer, default=0)
    wrong_answers_reviewed = Column(Integer, default=0)
    study_time_minutes = Column(Integer, default=0)  # 학습 시간 (분)
    
    # 점수 및 성과
    average_score = Column(Integer)  # 평균 점수
    questions_solved = Column(Integer, default=0)  # 푼 문제 수
    correct_answers = Column(Integer, default=0)  # 정답 수
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # 관계 설정
    user = relationship("User")
    learning_streak = relationship("LearningStreak", back_populates="daily_activities")


class Achievement(Base):
    """성취 뱃지 테이블
    
    사용자가 달성한 성취를 기록합니다.
    """
    __tablename__ = "achievements"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    achievement_type = Column(String(50), nullable=False)  # streak, score, consistency 등
    achievement_key = Column(String(100), nullable=False)  # 구체적인 성취 키
    title = Column(String(200), nullable=False)  # 성취 제목
    description = Column(String(500))  # 성취 설명
    icon = Column(String(100))  # 아이콘 이름
    color = Column(String(20))  # 색상 코드
    earned_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 관계 설정
    user = relationship("User")


# Pydantic 모델들
class LearningStreakResponse(BaseModel):
    """학습 스트릭 응답 모델"""
    current_streak: int
    longest_streak: int
    last_activity_date: Optional[date]
    total_study_days: int
    is_active_today: bool
    
    class Config:
        from_attributes = True


class DailyActivityCreate(BaseModel):
    """일일 활동 생성 모델"""
    diagnostic_completed: bool = False
    daily_tests_completed: int = 0
    wrong_answers_reviewed: int = 0
    study_time_minutes: int = 0
    average_score: Optional[int] = None
    questions_solved: int = 0
    correct_answers: int = 0


class DailyActivityResponse(BaseModel):
    """일일 활동 응답 모델"""
    id: int
    activity_date: date
    diagnostic_completed: bool
    daily_tests_completed: int
    wrong_answers_reviewed: int
    study_time_minutes: int
    average_score: Optional[int]
    questions_solved: int
    correct_answers: int
    accuracy_rate: float
    
    class Config:
        from_attributes = True
    
    @property
    def accuracy_rate(self) -> float:
        if self.questions_solved == 0:
            return 0.0
        return self.correct_answers / self.questions_solved


class AchievementResponse(BaseModel):
    """성취 응답 모델"""
    id: int
    achievement_type: str
    achievement_key: str
    title: str
    description: Optional[str]
    icon: Optional[str]
    color: Optional[str]
    earned_at: datetime
    
    class Config:
        from_attributes = True


class LearningStats(BaseModel):
    """학습 통계 모델"""
    streak: LearningStreakResponse
    recent_activities: List[DailyActivityResponse]
    recent_achievements: List[AchievementResponse]
    weekly_summary: dict
    monthly_summary: dict
