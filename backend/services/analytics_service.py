from typing import List, Dict, Any
from datetime import datetime, timedelta
import random
from models.database import SessionLocal
from models.user import User
from models.diagnostic import DiagnosticResult
from models.daily_test import DailyTestResult
from services.auth_service import AuthService

class AnalyticsService:
    def __init__(self):
        self.auth_service = AuthService()
        self.db = SessionLocal()
    
    def get_user_dashboard(self, user_id: int) -> Dict[str, Any]:
        """사용자 대시보드 데이터 조회"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "사용자를 찾을 수 없습니다."}
        
        # 기본 통계 계산
        stats = self._calculate_basic_stats(user_id)
        
        # 학습 진행도 계산
        progress = self._calculate_progress(user)
        
        # 최근 활동
        recent_activity = self._get_recent_activity(user_id)
        
        # 추천 사항
        recommendations = self._generate_recommendations(user, stats)
        
        return {
            "user_info": {
                "name": user.name,
                "grade": user.grade,
                "target_grade": user.target_grade,
                "study_time": user.study_time,
                "learning_style": user.learning_style
            },
            "stats": stats,
            "progress": progress,
            "recent_activity": recent_activity,
            "recommendations": recommendations
        }
    
    def generate_weekly_report(self, user_id: int) -> Dict[str, Any]:
        """주간 학습 리포트 생성"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "사용자를 찾을 수 없습니다."}
        
        # 주간 통계 계산
        weekly_stats = self._calculate_weekly_stats(user_id)
        
        # 학습 패턴 분석
        learning_pattern = self._analyze_learning_pattern(user_id)
        
        # 다음 주 목표 설정
        next_week_goals = self._set_next_week_goals(user, weekly_stats)
        
        return {
            "user_id": user_id,
            "week_period": {
                "start": (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d"),
                "end": datetime.now().strftime("%Y-%m-%d")
            },
            "weekly_stats": weekly_stats,
            "learning_pattern": learning_pattern,
            "next_week_goals": next_week_goals,
            "generated_at": datetime.now()
        }
    
    def get_user_wrong_notes(self, user_id: int) -> List[Dict[str, Any]]:
        """사용자의 오답 노트 조회"""
        # 실제로는 별도 테이블에서 조회해야 하지만,
        # 여기서는 더미 데이터 반환
        return [
            {
                "id": 1,
                "question_content": "현상적 보수주의에 대한 설명으로 옳은 것은?",
                "user_answer": "①",
                "correct_answer": "②",
                "explanation": "현상적 보수주의는 '다른 반대 증거가 없다면'이라는 조건을 통해 '그렇게 보임'이 제공하는 정당성이 '잠정적'임을 명시하고 있다.",
                "unit": "언어이해-인식론",
                "points": 4,
                "added_at": datetime.now() - timedelta(days=2),
                "review_count": 1,
                "mastered": False
            },
            {
                "id": 2,
                "question_content": "시냅스 가소성에 대한 설명으로 틀린 것은?",
                "user_answer": "④",
                "correct_answer": "④",
                "explanation": "LTD는 불필요한 기억을 지우거나 기존 회로를 재조정하는 역할을 한다. 기억을 공고히 하는 것과는 반대되는 기능이다.",
                "unit": "언어이해-신경과학",
                "points": 4,
                "added_at": datetime.now() - timedelta(days=1),
                "review_count": 0,
                "mastered": False
            },
            {
                "id": 3,
                "question_content": "다음 중 형식적으로 타당한 논증은?",
                "user_answer": "①",
                "correct_answer": "③",
                "explanation": "이는 타당한 삼단논법(특칭긍정+전칭긍정)의 형식을 따른다.",
                "unit": "추리논증-논리학",
                "points": 4,
                "added_at": datetime.now() - timedelta(days=3),
                "review_count": 2,
                "mastered": True
            }
        ]
    
    def _calculate_basic_stats(self, user_id: int) -> Dict[str, Any]:
        """기본 통계 계산"""
        # 진단 결과 조회
        diagnostic_results = self.db.query(DiagnosticResult).filter(
            DiagnosticResult.user_id == user_id
        ).all()
        
        # 일일 모의고사 결과 조회
        daily_test_results = self.db.query(DailyTestResult).filter(
            DailyTestResult.user_id == user_id
        ).all()
        
        # 통계 계산
        total_study_days = len(daily_test_results)
        total_questions_solved = sum(len(result.wrong_questions or []) + result.correct_count for result in daily_test_results)
        
        if daily_test_results:
            average_score = sum(result.accuracy for result in daily_test_results) / len(daily_test_results)
            total_wrong_questions = sum(len(result.wrong_questions or []) for result in daily_test_results)
        else:
            average_score = 0
            total_wrong_questions = 0
        
        # 연속 학습일 계산 (간단한 로직)
        consecutive_days = self._calculate_consecutive_days(daily_test_results)
        
        # 강점/약점 단원 분석
        strongest_unit, weakest_unit = self._analyze_unit_performance(daily_test_results)
        
        return {
            "total_study_days": total_study_days,
            "consecutive_days": consecutive_days,
            "total_questions_solved": total_questions_solved,
            "average_score": round(average_score, 1),
            "total_wrong_questions": total_wrong_questions,
            "strongest_unit": strongest_unit,
            "weakest_unit": weakest_unit,
            "current_streak": consecutive_days,
            "best_streak": consecutive_days  # 실제로는 더 복잡한 계산 필요
        }
    
    def _calculate_progress(self, user: User) -> Dict[str, Any]:
        """학습 진행도 계산"""
        # 리트 점수 기반 진행도 (간단한 추정)
        def _parse_score(text: str) -> int:
            try:
                return int(str(text).replace("점", "").strip())
            except Exception:
                return 0

        current_score = _parse_score(user.grade)
        target_score = _parse_score(user.target_grade)

        if target_score <= 0:
            target_score = 200

        progress_percentage = max(0, min(100, (current_score / target_score) * 100))

        return {
            "current_grade": f"{current_score}점" if current_score else user.grade,
            "target_grade": f"{target_score}점",
            "progress_percentage": progress_percentage,
            "remaining_gap": max(0, target_score - current_score),
            "estimated_completion": self._estimate_completion_date(3 if progress_percentage < 60 else 1)
        }
    
    def _get_recent_activity(self, user_id: int) -> List[Dict[str, Any]]:
        """최근 활동 조회"""
        activities = []
        
        # 최근 일일 모의고사 결과 조회
        recent_daily_tests = self.db.query(DailyTestResult).filter(
            DailyTestResult.user_id == user_id
        ).order_by(DailyTestResult.completed_at.desc()).limit(5).all()
        
        for test in recent_daily_tests:
            activities.append({
                "type": "daily_test",
                "title": "일일 모의고사 완료",
                "description": f"{test.total_questions}문제 중 {test.correct_count}문제 정답",
                "score": test.accuracy,
                "timestamp": test.completed_at
            })
        
        # 최근 진단 평가 결과 조회
        recent_diagnostic = self.db.query(DiagnosticResult).filter(
            DiagnosticResult.user_id == user_id
        ).order_by(DiagnosticResult.completed_at.desc()).first()
        
        if recent_diagnostic:
            activities.append({
                "type": "diagnostic",
                "title": "진단 평가 완료",
                "description": f"예상 등급: {recent_diagnostic.estimated_grade}",
                "score": recent_diagnostic.accuracy,
                "timestamp": recent_diagnostic.completed_at
            })
        
        # 활동을 시간순으로 정렬
        activities.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return activities[:10]  # 최근 10개 활동만 반환
    
    def _generate_recommendations(self, user: User, stats: Dict[str, Any]) -> List[str]:
        """추천 사항 생성"""
        recommendations = []
        
        # 연속 학습 관련
        if stats["consecutive_days"] < 3:
            recommendations.append("연속 학습을 통해 학습 습관을 만들어보세요.")
        
        # 정답률 관련
        if stats["average_score"] < 70:
            recommendations.append("오답 노트를 꼼꼼히 복습하여 정답률을 높여보세요.")
        
        # 약점 단원 관련
        if stats["weakest_unit"]:
            recommendations.append(f"{stats['weakest_unit']} 단원에 더 많은 시간을 투자해보세요.")
        
        # 목표 등급 관련
        grade_points = {"1등급": 1, "2등급": 2, "3등급": 3, "4등급": 4, "5등급": 5, "6등급": 6}
        current = grade_points.get(user.grade, 6)
        target = grade_points.get(user.target_grade, 1)
        
        if current - target > 2:
            recommendations.append("목표 등급까지의 격차가 큽니다. 체계적인 학습 계획을 세워보세요.")
        
        return recommendations
    
    def _calculate_weekly_stats(self, user_id: int) -> Dict[str, Any]:
        """주간 통계 계산"""
        # 더미 데이터 반환
        return {
            "questions_solved": 45,
            "average_score": 82.3,
            "study_days": 6,
            "total_study_time": 480,  # 분 단위
            "wrong_questions": 8,
            "improvement_rate": 5.2  # 전주 대비 개선률
        }
    
    def _analyze_learning_pattern(self, user_id: int) -> Dict[str, Any]:
        """학습 패턴 분석"""
        return {
            "preferred_study_time": "저녁",
            "most_productive_day": "수요일",
            "average_session_length": 45,  # 분
            "concentration_level": "높음",
            "weakest_time_slot": "오후 2-4시"
        }
    
    def _set_next_week_goals(self, user: User, weekly_stats: Dict[str, Any]) -> Dict[str, Any]:
        """다음 주 목표 설정"""
        current_questions = weekly_stats["questions_solved"]
        current_score = weekly_stats["average_score"]
        
        return {
            "target_questions": int(current_questions * 1.1),  # 10% 증가
            "target_score": min(current_score + 2, 100),  # 2점 증가
            "target_study_days": 7,
            "focus_units": ["미적분", "확률과통계"],
            "special_goals": [
                "오답 노트 5문제 복습",
                "고난도 문제 3문제 도전"
            ]
        }
    
    def _estimate_completion_date(self, gap: int) -> str:
        """목표 달성 예상일 계산"""
        if gap <= 1:
            return "1개월 내"
        elif gap <= 2:
            return "3개월 내"
        elif gap <= 3:
            return "6개월 내"
        else:
            return "1년 내"
    
    def _calculate_consecutive_days(self, daily_test_results: List[DailyTestResult]) -> int:
        """연속 학습일 계산"""
        if not daily_test_results:
            return 0
        
        # 날짜별로 정렬
        sorted_results = sorted(daily_test_results, key=lambda x: x.completed_at, reverse=True)
        
        consecutive_days = 0
        current_date = datetime.now().date()
        
        for result in sorted_results:
            result_date = result.completed_at.date()
            if (current_date - result_date).days == consecutive_days:
                consecutive_days += 1
            else:
                break
        
        return consecutive_days
    
    def _analyze_unit_performance(self, daily_test_results: List[DailyTestResult]) -> tuple:
        """단원별 성과 분석"""
        if not daily_test_results:
            return "민법총칙", "형법총론"
        
        unit_scores = {}
        
        for result in daily_test_results:
            if result.wrong_questions:
                for question in result.wrong_questions:
                    unit = question.get('unit', '기타')
                    if unit not in unit_scores:
                        unit_scores[unit] = {'correct': 0, 'total': 0}
                    unit_scores[unit]['total'] += 1
        
        if not unit_scores:
            return "민법총칙", "형법총론"
        
        # 정답률 계산
        unit_accuracies = {}
        for unit, scores in unit_scores.items():
            if scores['total'] > 0:
                unit_accuracies[unit] = (scores['correct'] / scores['total']) * 100
            else:
                unit_accuracies[unit] = 0
        
        # 강점/약점 단원 찾기
        if unit_accuracies:
            strongest_unit = max(unit_accuracies, key=unit_accuracies.get)
            weakest_unit = min(unit_accuracies, key=unit_accuracies.get)
        else:
            strongest_unit = "민법총칙"
            weakest_unit = "형법총론"
        
        return strongest_unit, weakest_unit 