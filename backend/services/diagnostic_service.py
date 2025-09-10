from typing import List, Dict, Any
from datetime import datetime
import random
import numpy as np
from sklearn.cluster import KMeans

from models.database import SessionLocal
from models.user import User
from models.question import QuestionBank, QuestionService
from models.diagnostic import DiagnosticResult
from services.auth_service import AuthService

class DiagnosticService:
    def __init__(self):
        self.question_service = QuestionService()
        self.auth_service = AuthService()
        self.db = SessionLocal()
    
    def get_diagnostic_questions(self) -> List[Dict[str, Any]]:
        """진단 평가 문제 목록 조회 (30문제)"""
        # 진단 평가용 문제 구성 (LEET 과목 중심)
        # 단원별, 난이도별로 균형있게 선택
        units = [
            "언어이해-인식론", "언어이해-신경과학", "언어이해-법학", 
            "추리논증-논리학", "추리논증-경제학", "추리논증-논리게임",
            "민법총칙", "물권법", "형법총론", "헌법-기본권", "상법-회사법"
        ]
        difficulties = [1, 2, 3, 4, 5]
        points = [3, 4, 5]
        
        questions = []
        
        # 각 단원별로 6-8문제씩 선택
        for unit in units:
            unit_questions = []
            for difficulty in difficulties:
                for point in points:
                    # 각 조합별로 1-2문제씩 선택
                    unit_difficulty_point_questions = self.question_service.get_questions_by_criteria(
                        unit=unit, difficulty=difficulty, points=point, limit=2
                    )
                    unit_questions.extend(unit_difficulty_point_questions)
            
            # 해당 단원에서 6-8문제 랜덤 선택
            selected_questions = random.sample(unit_questions, min(8, len(unit_questions)))
            questions.extend(selected_questions)
        
        # 총 30문제가 되도록 조정
        if len(questions) > 30:
            questions = random.sample(questions, 30)
        elif len(questions) < 30:
            # 부족한 경우 추가 문제 선택
            additional_questions = self.question_service.get_questions_by_criteria(limit=30-len(questions))
            questions.extend(additional_questions)
        
        return questions
    
    def process_diagnostic(self, user_id: int, answers: Dict[str, str]) -> Dict[str, Any]:
        """진단 평가 결과 처리"""
        # 문제 조회
        questions = []
        for question_id in answers.keys():
            question = self.question_service.get_question_by_id(int(question_id))
            if question:
                questions.append(question)
        
        # 점수 계산
        total_score = 0
        total_points = 0
        unit_scores = {}
        wrong_questions = []
        
        for question in questions:
            question_id = str(question.id)
            user_answer = answers.get(question_id, "")
            correct_answer = question.correct_answer
            
            total_points += question.points
            
            if user_answer == correct_answer:
                total_score += question.points
                # 단원별 점수 누적
                if question.unit not in unit_scores:
                    unit_scores[question.unit] = {"correct": 0, "total": 0}
                unit_scores[question.unit]["correct"] += question.points
                unit_scores[question.unit]["total"] += question.points
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
                # 단원별 점수 누적
                if question.unit not in unit_scores:
                    unit_scores[question.unit] = {"correct": 0, "total": 0}
                unit_scores[question.unit]["total"] += question.points
        
        # 정답률 계산
        accuracy = (total_score / total_points * 100) if total_points > 0 else 0
        
        # 예상 등급 산출 (간단한 로직)
        estimated_grade = self._estimate_grade(accuracy)
        
        # 강점/약점 단원 분석
        strong_units = []
        weak_units = []
        
        for unit, scores in unit_scores.items():
            unit_accuracy = (scores["correct"] / scores["total"] * 100) if scores["total"] > 0 else 0
            if unit_accuracy >= 70:
                strong_units.append(unit)
            elif unit_accuracy <= 30:
                weak_units.append(unit)
        
        # 결과 저장
        result = {
            "user_id": user_id,
            "total_score": total_score,
            "total_points": total_points,
            "accuracy": accuracy,
            "estimated_grade": estimated_grade,
            "strong_units": strong_units,
            "weak_units": weak_units,
            "unit_scores": unit_scores,
            "wrong_questions": wrong_questions,
            "completed_at": datetime.now()
        }
        
        # 데이터베이스에 진단 결과 저장
        diagnostic_result = DiagnosticResult(
            user_id=user_id,
            total_score=total_score,
            total_points=total_points,
            accuracy=accuracy,
            estimated_grade=estimated_grade,
            strong_units=strong_units,
            weak_units=weak_units,
            unit_scores=unit_scores,
            wrong_questions=wrong_questions
        )
        
        self.db.add(diagnostic_result)
        
        # 사용자 진단 완료 상태 업데이트
        user = self.db.query(User).filter(User.id == user_id).first()
        if user:
            user.diagnostic_completed = True
            user.grade = estimated_grade  # 예상 등급으로 업데이트
        
        self.db.commit()
        
        return result
    
    def get_user_diagnostic_result(self, user_id: int) -> Dict[str, Any]:
        """사용자의 최근 진단 결과 조회"""
        # 가장 최근 진단 결과 조회
        latest_result = self.db.query(DiagnosticResult).filter(
            DiagnosticResult.user_id == user_id
        ).order_by(DiagnosticResult.completed_at.desc()).first()
        
        if latest_result:
            return {
                "diagnostic_completed": True,
                "result": latest_result.to_dict()
            }
        
        # 진단 결과가 없으면 사용자 정보에서 확인
        user = self.db.query(User).filter(User.id == user_id).first()
        if user and user.diagnostic_completed:
            return {
                "diagnostic_completed": True,
                "user_info": {
                    "grade": user.grade,
                    "target_grade": user.target_grade
                }
            }
        
        return {"diagnostic_completed": False}
    
    def analyze_learning_pattern(self, user_id: int) -> Dict[str, Any]:
        """학습 패턴 분석 및 전략 제안"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "사용자를 찾을 수 없습니다."}
        
        # 간단한 학습 전략 제안
        strategies = {
            "concept_first": "개념 이해를 우선으로 하는 학습",
            "problem_focused": "문제 풀이 중심의 학습",
            "mixed": "개념과 문제 풀이를 병행하는 학습"
        }
        
        recommended_strategy = strategies.get(user.learning_style, "mixed")
        
        return {
            "user_id": user_id,
            "current_grade": user.grade,
            "target_grade": user.target_grade,
            "study_time": user.study_time,
            "learning_style": user.learning_style,
            "recommended_strategy": recommended_strategy,
            "daily_goal": self._calculate_daily_goal(user.grade, user.target_grade)
        }
    
    def _estimate_grade(self, accuracy: float) -> str:
        """정답률을 바탕으로 예상 점수 산출 (리트 시험 기준)"""
        if accuracy >= 90:
            return "180점"
        elif accuracy >= 80:
            return "160점"
        elif accuracy >= 70:
            return "140점"
        elif accuracy >= 60:
            return "120점"
        elif accuracy >= 50:
            return "100점"
        else:
            return "80점"
    
    def _calculate_daily_goal(self, current_grade: str, target_grade: str) -> Dict[str, Any]:
        """일일 학습 목표 계산 (리트 시험 기준)"""
        # 점수를 숫자로 변환 (예: "150점" -> 150)
        def extract_score(grade_str):
            if "점" in grade_str:
                return int(grade_str.replace("점", ""))
            return 100  # 기본값
        
        current = extract_score(current_grade)
        target = extract_score(target_grade)
        
        gap = target - current  # 목표점수 - 현재점수
        
        if gap <= 20:
            return {"questions": 10, "focus": "유지 및 심화"}
        elif gap <= 40:
            return {"questions": 15, "focus": "약점 보완"}
        else:
            return {"questions": 20, "focus": "기초 다지기"} 