"""
학습 스트릭 서비스

사용자의 연속 학습 일수와 학습 습관을 관리하는 서비스입니다.
"""

from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy import and_, desc, func
from datetime import datetime, date, timedelta
from typing import List, Dict, Any, Optional

from models.database import SessionLocal
from models.learning_streak import (
    LearningStreak, DailyActivity, Achievement,
    LearningStreakResponse, DailyActivityCreate, DailyActivityResponse,
    AchievementResponse, LearningStats
)
from models.user import User


class LearningStreakService:
    """학습 스트릭 관리 서비스
    
    연속 학습 일수 추적, 일일 활동 기록, 성취 시스템 등을 제공합니다.
    """
    
    def __init__(self):
        self.db = SessionLocal()
    
    def get_or_create_streak(self, user_id: int) -> LearningStreak:
        """사용자의 학습 스트릭을 가져오거나 생성합니다"""
        streak = self.db.query(LearningStreak).filter(
            LearningStreak.user_id == user_id
        ).first()
        
        if not streak:
            streak = LearningStreak(
                user_id=user_id,
                current_streak=0,
                longest_streak=0,
                total_study_days=0
            )
            self.db.add(streak)
            self.db.commit()
            self.db.refresh(streak)
        
        return streak
    
    def record_daily_activity(self, user_id: int, activity_data: DailyActivityCreate) -> DailyActivityResponse:
        """일일 학습 활동을 기록합니다"""
        today = date.today()
        streak = self.get_or_create_streak(user_id)
        
        # 오늘 활동이 이미 있는지 확인
        existing_activity = self.db.query(DailyActivity).filter(
            and_(
                DailyActivity.user_id == user_id,
                DailyActivity.activity_date == today
            )
        ).first()
        
        if existing_activity:
            # 기존 활동 업데이트
            for field, value in activity_data.dict().items():
                if hasattr(existing_activity, field):
                    current_value = getattr(existing_activity, field)
                    if isinstance(current_value, int) and isinstance(value, int):
                        # 정수 필드는 누적
                        setattr(existing_activity, field, current_value + value)
                    else:
                        # 불린이나 기타 필드는 덮어쓰기
                        setattr(existing_activity, field, value)
            
            existing_activity.updated_at = datetime.now()
            activity = existing_activity
        else:
            # 새 활동 생성
            activity = DailyActivity(
                user_id=user_id,
                learning_streak_id=streak.id,
                activity_date=today,
                **activity_data.dict()
            )
            self.db.add(activity)
        
        # 스트릭 업데이트
        self._update_streak(user_id, today)
        
        self.db.commit()
        self.db.refresh(activity)
        
        # 성취 확인
        self._check_achievements(user_id)
        
        return DailyActivityResponse.from_orm(activity)
    
    def _update_streak(self, user_id: int, activity_date: date):
        """스트릭을 업데이트합니다"""
        streak = self.get_or_create_streak(user_id)
        
        if streak.last_activity_date is None:
            # 첫 활동
            streak.current_streak = 1
            streak.longest_streak = 1
            streak.total_study_days = 1
        elif streak.last_activity_date == activity_date:
            # 같은 날 - 스트릭 유지
            pass
        elif streak.last_activity_date == activity_date - timedelta(days=1):
            # 연속된 날 - 스트릭 증가
            streak.current_streak += 1
            streak.total_study_days += 1
            if streak.current_streak > streak.longest_streak:
                streak.longest_streak = streak.current_streak
        else:
            # 연속되지 않은 날 - 스트릭 리셋
            streak.current_streak = 1
            streak.total_study_days += 1
        
        streak.last_activity_date = activity_date
        streak.updated_at = datetime.now()
        self.db.commit()
    
    def get_learning_streak(self, user_id: int) -> LearningStreakResponse:
        """사용자의 학습 스트릭 정보를 조회합니다"""
        streak = self.get_or_create_streak(user_id)
        today = date.today()
        
        # 오늘 활동 여부 확인
        today_activity = self.db.query(DailyActivity).filter(
            and_(
                DailyActivity.user_id == user_id,
                DailyActivity.activity_date == today
            )
        ).first()
        
        is_active_today = today_activity is not None
        
        # 스트릭이 깨졌는지 확인 (마지막 활동이 어제가 아닌 경우)
        if (streak.last_activity_date and 
            streak.last_activity_date < today - timedelta(days=1) and
            streak.current_streak > 0):
            streak.current_streak = 0
            self.db.commit()
        
        return LearningStreakResponse(
            current_streak=streak.current_streak,
            longest_streak=streak.longest_streak,
            last_activity_date=streak.last_activity_date,
            total_study_days=streak.total_study_days,
            is_active_today=is_active_today
        )
    
    def get_daily_activities(self, user_id: int, days: int = 30) -> List[DailyActivityResponse]:
        """사용자의 최근 일일 활동을 조회합니다"""
        start_date = date.today() - timedelta(days=days-1)
        
        activities = self.db.query(DailyActivity).filter(
            and_(
                DailyActivity.user_id == user_id,
                DailyActivity.activity_date >= start_date
            )
        ).order_by(desc(DailyActivity.activity_date)).all()
        
        return [DailyActivityResponse.from_orm(activity) for activity in activities]
    
    def _check_achievements(self, user_id: int):
        """성취 달성 여부를 확인하고 새로운 성취를 부여합니다"""
        streak = self.get_or_create_streak(user_id)
        
        # 기존 성취 목록
        existing_achievements = set(
            achievement.achievement_key for achievement in 
            self.db.query(Achievement).filter(Achievement.user_id == user_id).all()
        )
        
        new_achievements = []
        
        # 스트릭 관련 성취
        streak_achievements = [
            (3, "첫걸음", "3일 연속 학습을 달성했습니다!", "streak_3", "🔥"),
            (7, "일주일 챌린지", "7일 연속 학습을 달성했습니다!", "streak_7", "⭐"),
            (14, "2주 마스터", "14일 연속 학습을 달성했습니다!", "streak_14", "🏆"),
            (30, "한달 챔피언", "30일 연속 학습을 달성했습니다!", "streak_30", "👑"),
            (100, "백일장", "100일 연속 학습을 달성했습니다!", "streak_100", "💎"),
        ]
        
        for days, title, description, key, icon in streak_achievements:
            if (streak.current_streak >= days and 
                key not in existing_achievements):
                new_achievements.append(Achievement(
                    user_id=user_id,
                    achievement_type="streak",
                    achievement_key=key,
                    title=title,
                    description=description,
                    icon=icon,
                    color="#FF6B35"
                ))
        
        # 총 학습일 관련 성취
        total_achievements = [
            (50, "꾸준한 학습자", "총 50일 학습을 완료했습니다!", "total_50", "📚"),
            (100, "학습 애호가", "총 100일 학습을 완료했습니다!", "total_100", "🎓"),
            (200, "학습 전문가", "총 200일 학습을 완료했습니다!", "total_200", "🧠"),
            (365, "1년 마스터", "총 365일 학습을 완료했습니다!", "total_365", "🌟"),
        ]
        
        for days, title, description, key, icon in total_achievements:
            if (streak.total_study_days >= days and 
                key not in existing_achievements):
                new_achievements.append(Achievement(
                    user_id=user_id,
                    achievement_type="consistency",
                    achievement_key=key,
                    title=title,
                    description=description,
                    icon=icon,
                    color="#4ECDC4"
                ))
        
        # 새 성취 저장
        if new_achievements:
            for achievement in new_achievements:
                self.db.add(achievement)
            self.db.commit()
    
    def get_user_achievements(self, user_id: int) -> List[AchievementResponse]:
        """사용자의 성취 목록을 조회합니다"""
        achievements = self.db.query(Achievement).filter(
            Achievement.user_id == user_id
        ).order_by(desc(Achievement.earned_at)).all()
        
        return [AchievementResponse.from_orm(achievement) for achievement in achievements]
    
    def get_learning_stats(self, user_id: int) -> LearningStats:
        """종합 학습 통계를 조회합니다"""
        streak = self.get_learning_streak(user_id)
        recent_activities = self.get_daily_activities(user_id, 7)
        recent_achievements = self.get_user_achievements(user_id)[:5]  # 최근 5개
        
        # 주간 요약
        weekly_summary = self._get_weekly_summary(user_id)
        
        # 월간 요약
        monthly_summary = self._get_monthly_summary(user_id)
        
        return LearningStats(
            streak=streak,
            recent_activities=recent_activities,
            recent_achievements=recent_achievements,
            weekly_summary=weekly_summary,
            monthly_summary=monthly_summary
        )
    
    def _get_weekly_summary(self, user_id: int) -> Dict[str, Any]:
        """주간 요약 통계를 생성합니다"""
        start_date = date.today() - timedelta(days=7)
        
        activities = self.db.query(DailyActivity).filter(
            and_(
                DailyActivity.user_id == user_id,
                DailyActivity.activity_date >= start_date
            )
        ).all()
        
        if not activities:
            return {
                "study_days": 0,
                "total_study_time": 0,
                "total_questions": 0,
                "average_score": 0,
                "consistency_rate": 0.0
            }
        
        total_study_time = sum(activity.study_time_minutes for activity in activities)
        total_questions = sum(activity.questions_solved for activity in activities)
        total_correct = sum(activity.correct_answers for activity in activities)
        
        scores = [activity.average_score for activity in activities if activity.average_score]
        average_score = sum(scores) / len(scores) if scores else 0
        
        return {
            "study_days": len(activities),
            "total_study_time": total_study_time,
            "total_questions": total_questions,
            "average_score": round(average_score, 1),
            "accuracy_rate": round(total_correct / total_questions * 100, 1) if total_questions > 0 else 0,
            "consistency_rate": round(len(activities) / 7 * 100, 1)
        }
    
    def _get_monthly_summary(self, user_id: int) -> Dict[str, Any]:
        """월간 요약 통계를 생성합니다"""
        start_date = date.today() - timedelta(days=30)
        
        activities = self.db.query(DailyActivity).filter(
            and_(
                DailyActivity.user_id == user_id,
                DailyActivity.activity_date >= start_date
            )
        ).all()
        
        if not activities:
            return {
                "study_days": 0,
                "total_study_time": 0,
                "total_questions": 0,
                "average_score": 0,
                "consistency_rate": 0.0
            }
        
        total_study_time = sum(activity.study_time_minutes for activity in activities)
        total_questions = sum(activity.questions_solved for activity in activities)
        total_correct = sum(activity.correct_answers for activity in activities)
        
        scores = [activity.average_score for activity in activities if activity.average_score]
        average_score = sum(scores) / len(scores) if scores else 0
        
        return {
            "study_days": len(activities),
            "total_study_time": total_study_time,
            "total_questions": total_questions,
            "average_score": round(average_score, 1),
            "accuracy_rate": round(total_correct / total_questions * 100, 1) if total_questions > 0 else 0,
            "consistency_rate": round(len(activities) / 30 * 100, 1)
        }
    
    def __del__(self):
        """소멸자에서 데이터베이스 연결 해제"""
        if hasattr(self, 'db'):
            self.db.close()
