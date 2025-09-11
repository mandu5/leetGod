"""
오답 노트 서비스

사용자의 틀린 문제들을 관리하고 복습 시스템을 제공하는 서비스입니다.
"""

from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy import and_, or_, desc, func
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import random

from models.database import SessionLocal
from models.wrong_answer import (
    WrongAnswer, WrongAnswerReview,
    WrongAnswerCreate, WrongAnswerResponse,
    WrongAnswerReviewCreate, WrongAnswerReviewResponse,
    WrongAnswerFilter, WrongAnswerStats
)
from models.user import User
from services.auth_service import AuthService


class WrongAnswerService:
    """오답 노트 관리 서비스
    
    틀린 문제 저장, 조회, 복습 관리 등의 기능을 제공합니다.
    """
    
    def __init__(self):
        self.db = SessionLocal()
        self.auth_service = AuthService()
    
    def add_wrong_answer(self, user_id: int, wrong_answer_data: WrongAnswerCreate) -> WrongAnswerResponse:
        """오답 노트에 틀린 문제 추가
        
        Args:
            user_id: 사용자 ID
            wrong_answer_data: 틀린 문제 데이터
            
        Returns:
            생성된 오답 노트 항목
        """
        # 중복 체크 (같은 문제를 이미 틀렸는지 확인)
        existing = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.user_id == user_id,
                WrongAnswer.question_id == wrong_answer_data.question_id,
                WrongAnswer.source_type == wrong_answer_data.source_type
            )
        ).first()
        
        if existing:
            # 이미 존재하는 경우 업데이트
            existing.user_answer = wrong_answer_data.user_answer
            existing.updated_at = datetime.now()
            self.db.commit()
            self.db.refresh(existing)
            return WrongAnswerResponse.from_orm(existing)
        
        # 새로운 오답 노트 항목 생성
        wrong_answer = WrongAnswer(
            user_id=user_id,
            **wrong_answer_data.dict()
        )
        
        self.db.add(wrong_answer)
        self.db.commit()
        self.db.refresh(wrong_answer)
        
        return WrongAnswerResponse.from_orm(wrong_answer)
    
    def get_wrong_answers(self, user_id: int, filters: WrongAnswerFilter) -> List[WrongAnswerResponse]:
        """사용자의 오답 노트 조회
        
        Args:
            user_id: 사용자 ID
            filters: 필터링 조건
            
        Returns:
            필터링된 오답 노트 목록
        """
        query = self.db.query(WrongAnswer).filter(WrongAnswer.user_id == user_id)
        
        # 필터 적용
        if filters.subject:
            query = query.filter(WrongAnswer.subject == filters.subject)
        
        if filters.unit:
            query = query.filter(WrongAnswer.unit == filters.unit)
        
        if filters.difficulty_min is not None:
            query = query.filter(WrongAnswer.difficulty >= filters.difficulty_min)
        
        if filters.difficulty_max is not None:
            query = query.filter(WrongAnswer.difficulty <= filters.difficulty_max)
        
        if filters.mastered is not None:
            query = query.filter(WrongAnswer.mastered == filters.mastered)
        
        if filters.source_type:
            query = query.filter(WrongAnswer.source_type == filters.source_type)
        
        # 정렬 및 페이징
        query = query.order_by(desc(WrongAnswer.created_at))
        query = query.offset(filters.offset).limit(filters.limit)
        
        wrong_answers = query.all()
        return [WrongAnswerResponse.from_orm(wa) for wa in wrong_answers]
    
    def get_wrong_answer_by_id(self, user_id: int, wrong_answer_id: int) -> Optional[WrongAnswerResponse]:
        """특정 오답 노트 항목 조회
        
        Args:
            user_id: 사용자 ID
            wrong_answer_id: 오답 노트 항목 ID
            
        Returns:
            오답 노트 항목 또는 None
        """
        wrong_answer = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.id == wrong_answer_id,
                WrongAnswer.user_id == user_id
            )
        ).first()
        
        if not wrong_answer:
            return None
        
        return WrongAnswerResponse.from_orm(wrong_answer)
    
    def review_wrong_answer(self, user_id: int, wrong_answer_id: int, 
                          review_data: WrongAnswerReviewCreate) -> WrongAnswerReviewResponse:
        """오답 노트 문제 복습
        
        Args:
            user_id: 사용자 ID
            wrong_answer_id: 오답 노트 항목 ID
            review_data: 복습 데이터
            
        Returns:
            복습 기록
        """
        # 오답 노트 항목 확인
        wrong_answer = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.id == wrong_answer_id,
                WrongAnswer.user_id == user_id
            )
        ).first()
        
        if not wrong_answer:
            raise ValueError("해당 오답 노트 항목을 찾을 수 없습니다.")
        
        # 복습 기록 생성
        review = WrongAnswerReview(
            wrong_answer_id=wrong_answer_id,
            **review_data.dict()
        )
        
        self.db.add(review)
        
        # 오답 노트 항목 업데이트
        wrong_answer.review_count += 1
        wrong_answer.last_reviewed_at = datetime.now()
        
        # 마스터 여부 판단 (연속 3번 정답 시 마스터)
        if review_data.is_correct:
            recent_reviews = self.db.query(WrongAnswerReview).filter(
                WrongAnswerReview.wrong_answer_id == wrong_answer_id
            ).order_by(desc(WrongAnswerReview.created_at)).limit(2).all()
            
            all_correct = all(r.is_correct for r in recent_reviews)
            if all_correct and len(recent_reviews) >= 2:  # 이번 포함 3번 연속 정답
                wrong_answer.mastered = True
                wrong_answer.mastered_at = datetime.now()
        else:
            # 틀렸으면 마스터 해제
            wrong_answer.mastered = False
            wrong_answer.mastered_at = None
        
        self.db.commit()
        self.db.refresh(review)
        
        return WrongAnswerReviewResponse.from_orm(review)
    
    def get_wrong_answer_stats(self, user_id: int) -> WrongAnswerStats:
        """오답 노트 통계 조회
        
        Args:
            user_id: 사용자 ID
            
        Returns:
            오답 노트 통계
        """
        # 기본 통계
        total_count = self.db.query(WrongAnswer).filter(WrongAnswer.user_id == user_id).count()
        mastered_count = self.db.query(WrongAnswer).filter(
            and_(WrongAnswer.user_id == user_id, WrongAnswer.mastered == True)
        ).count()
        
        # 복습 필요한 문제 (마지막 복습 후 3일 이상 지난 문제)
        three_days_ago = datetime.now() - timedelta(days=3)
        review_needed_count = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.user_id == user_id,
                WrongAnswer.mastered == False,
                or_(
                    WrongAnswer.last_reviewed_at.is_(None),
                    WrongAnswer.last_reviewed_at < three_days_ago
                )
            )
        ).count()
        
        # 과목별 통계
        by_subject = {}
        subject_stats = self.db.query(
            WrongAnswer.subject, 
            func.count(WrongAnswer.id).label('count')
        ).filter(WrongAnswer.user_id == user_id).group_by(WrongAnswer.subject).all()
        
        for subject, count in subject_stats:
            by_subject[subject or '기타'] = count
        
        # 단원별 통계
        by_unit = {}
        unit_stats = self.db.query(
            WrongAnswer.unit,
            func.count(WrongAnswer.id).label('count')
        ).filter(WrongAnswer.user_id == user_id).group_by(WrongAnswer.unit).all()
        
        for unit, count in unit_stats:
            by_unit[unit or '기타'] = count
        
        # 난이도별 통계
        by_difficulty = {}
        difficulty_ranges = [(1.0, 2.0), (2.0, 3.0), (3.0, 4.0), (4.0, 5.0)]
        for min_diff, max_diff in difficulty_ranges:
            count = self.db.query(WrongAnswer).filter(
                and_(
                    WrongAnswer.user_id == user_id,
                    WrongAnswer.difficulty >= min_diff,
                    WrongAnswer.difficulty < max_diff
                )
            ).count()
            by_difficulty[f"{min_diff}-{max_diff}"] = count
        
        # 최근 복습 기록
        recent_reviews_query = self.db.query(WrongAnswerReview).join(WrongAnswer).filter(
            WrongAnswer.user_id == user_id
        ).order_by(desc(WrongAnswerReview.created_at)).limit(5)
        
        recent_reviews = [WrongAnswerReviewResponse.from_orm(r) for r in recent_reviews_query.all()]
        
        return WrongAnswerStats(
            total_count=total_count,
            mastered_count=mastered_count,
            review_needed_count=review_needed_count,
            by_subject=by_subject,
            by_unit=by_unit,
            by_difficulty=by_difficulty,
            recent_reviews=recent_reviews
        )
    
    def get_review_recommendations(self, user_id: int, limit: int = 10) -> List[WrongAnswerResponse]:
        """복습 추천 문제 조회
        
        망각 곡선을 고려하여 복습이 필요한 문제들을 추천합니다.
        
        Args:
            user_id: 사용자 ID
            limit: 반환할 문제 수
            
        Returns:
            복습 추천 문제 목록
        """
        now = datetime.now()
        
        # 복습 우선순위 계산
        # 1. 마스터되지 않은 문제
        # 2. 마지막 복습 후 시간이 많이 지난 문제
        # 3. 난이도가 높은 문제
        # 4. 틀린 횟수가 많은 문제
        
        query = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.user_id == user_id,
                WrongAnswer.mastered == False
            )
        )
        
        # 복습 우선순위에 따라 정렬
        # (마지막 복습 시간이 오래된 순서, 난이도 높은 순서)
        query = query.order_by(
            WrongAnswer.last_reviewed_at.asc().nullsfirst(),
            desc(WrongAnswer.difficulty),
            desc(WrongAnswer.review_count)
        )
        
        wrong_answers = query.limit(limit).all()
        return [WrongAnswerResponse.from_orm(wa) for wa in wrong_answers]
    
    def delete_wrong_answer(self, user_id: int, wrong_answer_id: int) -> bool:
        """오답 노트 항목 삭제
        
        Args:
            user_id: 사용자 ID
            wrong_answer_id: 오답 노트 항목 ID
            
        Returns:
            삭제 성공 여부
        """
        wrong_answer = self.db.query(WrongAnswer).filter(
            and_(
                WrongAnswer.id == wrong_answer_id,
                WrongAnswer.user_id == user_id
            )
        ).first()
        
        if not wrong_answer:
            return False
        
        # 관련 복습 기록도 함께 삭제
        self.db.query(WrongAnswerReview).filter(
            WrongAnswerReview.wrong_answer_id == wrong_answer_id
        ).delete()
        
        self.db.delete(wrong_answer)
        self.db.commit()
        
        return True
    
    def bulk_add_wrong_answers(self, user_id: int, wrong_answers: List[WrongAnswerCreate]) -> List[WrongAnswerResponse]:
        """여러 오답 노트 항목을 한 번에 추가
        
        일일 모의고사나 진단 평가 결과에서 틀린 문제들을 일괄 추가할 때 사용합니다.
        
        Args:
            user_id: 사용자 ID
            wrong_answers: 틀린 문제 데이터 목록
            
        Returns:
            생성된 오답 노트 항목 목록
        """
        created_items = []
        
        for wrong_answer_data in wrong_answers:
            try:
                item = self.add_wrong_answer(user_id, wrong_answer_data)
                created_items.append(item)
            except Exception as e:
                print(f"오답 노트 추가 실패: {e}")
                continue
        
        return created_items
    
    def __del__(self):
        """소멸자에서 데이터베이스 연결 해제"""
        if hasattr(self, 'db'):
            self.db.close()
