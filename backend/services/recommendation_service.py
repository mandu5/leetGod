from typing import List, Dict, Any
from datetime import datetime, timedelta
import random
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sqlalchemy import func

from models.database import SessionLocal
from models.user import User
from models.question import QuestionService
from models.daily_test import DailyTestResult
from services.auth_service import AuthService
from services.diagnostic_service import DiagnosticService

class RecommendationService:
    def __init__(self):
        self.question_service = QuestionService()
        self.auth_service = AuthService()
        self.diagnostic_service = DiagnosticService()
        self.db = SessionLocal()
    
    def generate_daily_test(self, user_id: int) -> Dict[str, Any]:
        """사용자 맞춤형 일일 모의고사 생성"""
        # 사용자 정보 조회
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "사용자를 찾을 수 없습니다."}
        
        # 진단 결과 조회
        diagnostic_result = self.diagnostic_service.get_user_diagnostic_result(user_id)
        
        # 문제 선택 전략
        questions = []
        
        if diagnostic_result.get("diagnostic_completed"):
            # 진단 결과가 있는 경우: 약점 단원 중심으로 문제 선택
            weak_units = diagnostic_result.get("weak_units", [])
            strong_units = diagnostic_result.get("strong_units", [])
            
            # 약점 단원에서 60%, 강점 단원에서 40% 선택
            weak_count = min(9, len(weak_units) * 2)  # 약점 단원에서 더 많은 문제
            strong_count = 6 - weak_count
            
            # 약점 단원 문제 선택
            for unit in weak_units[:3]:  # 최대 3개 단원
                unit_questions = self.question_service.get_questions_by_criteria(
                    unit=unit, limit=3
                )
                questions.extend(unit_questions[:3])
            
            # 강점 단원 문제 선택
            for unit in strong_units[:2]:  # 최대 2개 단원
                unit_questions = self.question_service.get_questions_by_criteria(
                    unit=unit, limit=3
                )
                questions.extend(unit_questions[:3])
        else:
            # 진단 결과가 없는 경우: 기본 문제 선택 (LEET 단원)
            units = [
                "언어이해-인식론", "언어이해-신경과학", "언어이해-법학",
                "추리논증-논리학", "추리논증-경제학", "추리논증-논리게임",
                "민법총칙", "물권법", "형법총론", "헌법-기본권", "상법-회사법"
            ]
            for unit in units:
                unit_questions = self.question_service.get_questions_by_criteria(
                    unit=unit, limit=4
                )
                questions.extend(unit_questions[:4])
        
        # 총 15문제로 조정
        if len(questions) > 15:
            questions = random.sample(questions, 15)
        elif len(questions) < 15:
            # 부족한 경우 추가 문제 선택
            additional_questions = self.question_service.get_questions_by_criteria(limit=15-len(questions))
            questions.extend(additional_questions)
        
        # 일일 모의고사 형식으로 변환
        daily_test = {
            "user_id": user_id,
            "questions": [
                {
                    "id": q["id"],
                    "content": q["content"],
                    "options": q["options"],
                    "points": q["points"],
                    "unit": q["unit"],
                    "question_number": i + 1
                }
                for i, q in enumerate(questions)
            ],
            "total_questions": len(questions),
            "estimated_time": self._calculate_estimated_time(questions),
            "created_at": datetime.now()
        }
        
        return daily_test
    
    def process_daily_test_result(self, user_id: int, answers: Dict[str, str]) -> Dict[str, Any]:
        """일일 모의고사 결과 처리"""
        # 문제 조회
        questions = []
        for question_id in answers.keys():
            question = self.question_service.get_question_by_id(int(question_id))
            if question:
                questions.append(question)
        
        # 점수 계산
        total_score = 0
        total_points = 0
        correct_count = 0
        wrong_questions = []
        
        for question in questions:
            question_id = str(question.id)
            user_answer = answers.get(question_id, "")
            correct_answer = question.correct_answer
            
            total_points += question.points
            
            if user_answer == correct_answer:
                total_score += question.points
                correct_count += 1
            else:
                wrong_questions.append({
                    "id": question.id,
                    "content": question.content,
                    "user_answer": user_answer,
                    "correct_answer": correct_answer,
                    "explanation": question.explanation,
                    "unit": question.unit,
                    "points": question.points
                })
        
        # 정답률 계산
        accuracy = (correct_count / len(questions) * 100) if questions else 0
        
        # 결과 저장
        result = {
            "user_id": user_id,
            "total_score": total_score,
            "total_points": total_points,
            "correct_count": correct_count,
            "total_questions": len(questions),
            "accuracy": accuracy,
            "wrong_questions": wrong_questions,
            "completed_at": datetime.now()
        }
        
        # 데이터베이스에 일일 모의고사 결과 저장
        daily_test_result = DailyTestResult(
            user_id=user_id,
            total_score=total_score,
            total_points=total_points,
            correct_count=correct_count,
            total_questions=len(questions),
            accuracy=accuracy,
            wrong_questions=wrong_questions
        )
        
        self.db.add(daily_test_result)
        self.db.commit()
        
        # 오답 노트 업데이트
        if wrong_questions:
            self._update_wrong_notes(user_id, wrong_questions)
        
        return result
    
    def _update_wrong_notes(self, user_id: int, wrong_questions: List[Dict[str, Any]]):
        """오답 노트 업데이트"""
        from services.wrong_answer_service import WrongAnswerService
        from models.wrong_answer import WrongAnswerCreate
        
        wrong_answer_service = WrongAnswerService()
        
        # 틀린 문제들을 오답 노트에 추가
        wrong_answer_items = []
        for question in wrong_questions:
            wrong_answer_data = WrongAnswerCreate(
                question_id=question['id'],
                question_content=question.get('content', ''),
                user_answer=question.get('user_answer', ''),
                correct_answer=question.get('correct_answer', ''),
                explanation=question.get('explanation', ''),
                unit=question.get('unit', ''),
                subject=question.get('subject', ''),
                topic=question.get('topic', ''),
                difficulty=question.get('difficulty', 3.0),
                points=question.get('points', 3),
                source_type='daily_test'
            )
            wrong_answer_items.append(wrong_answer_data)
        
        # 일괄 추가
        if wrong_answer_items:
            wrong_answer_service.bulk_add_wrong_answers(user_id, wrong_answer_items)
            print(f"사용자 {user_id}의 오답 노트에 {len(wrong_answer_items)}개 문제 추가")
    
    def _calculate_estimated_time(self, questions: List[Dict[str, Any]]) -> int:
        """예상 풀이 시간 계산 (분 단위)"""
        total_time = 0
        for question in questions:
            points = question.get("points", 3)
            # 배점에 따른 예상 시간: 3점=2분, 4점=3분, 5점=4분
            estimated_time = points + 1
            total_time += estimated_time
        
        return total_time
    
    def get_recommended_questions(self, user_id: int, unit: str = None, limit: int = 5) -> List[Dict[str, Any]]:
        """추천 문제 조회"""
        # 사용자 정보 조회
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        # 진단 결과 조회
        diagnostic_result = self.diagnostic_service.get_user_diagnostic_result(user_id)
        
        if diagnostic_result.get("diagnostic_completed"):
            # 진단 결과가 있는 경우: 약점 단원 우선
            weak_units = diagnostic_result.get("weak_units", [])
            if unit:
                target_unit = unit
            elif weak_units:
                target_unit = random.choice(weak_units)
            else:
                target_unit = "수학I"
        else:
            # 진단 결과가 없는 경우: 기본 단원
            target_unit = unit or "수학I"
        
        # 추천 문제 조회
        questions = self.question_service.get_questions_by_criteria(
            unit=target_unit, limit=limit
        )
        
        return questions
    
    def get_user_daily_test_history(self, user_id: int, limit: int = 10) -> List[Dict[str, Any]]:
        """사용자의 일일 모의고사 히스토리 조회"""
        results = self.db.query(DailyTestResult).filter(
            DailyTestResult.user_id == user_id
        ).order_by(DailyTestResult.completed_at.desc()).limit(limit).all()
        
        return [result.to_dict() for result in results]
    
    def get_today_daily_test(self, user_id: int) -> Dict[str, Any]:
        """오늘의 일일 모의고사 조회 (이미 완료했는지 확인)"""
        today = datetime.now().date()
        
        # 오늘 완료한 일일 모의고사가 있는지 확인
        today_result = self.db.query(DailyTestResult).filter(
            DailyTestResult.user_id == user_id,
            func.date(DailyTestResult.completed_at) == today
        ).first()
        
        if today_result:
            return {
                "already_completed": True,
                "result": today_result.to_dict()
            }
        
        # 오늘 완료하지 않았다면 새로운 일일 모의고사 생성
        return {
            "already_completed": False,
            "daily_test": self.generate_daily_test(user_id)
        } 