from fastapi import FastAPI, HTTPException, Depends, status, Form
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
import uvicorn
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

from models.database import init_db, get_db
from models.user import User, UserCreate, UserResponse
from models.question import QuestionBank
from services.auth_service import AuthService
from services.diagnostic_service import DiagnosticService
from services.recommendation_service import RecommendationService
from services.analytics_service import AnalyticsService
from services.voucher_service import VoucherService
from services.wrong_answer_service import WrongAnswerService
from services.learning_streak_service import LearningStreakService

load_dotenv()

# JWT 설정
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 시작 시 데이터베이스 초기화
    init_db()
    yield
    # 종료 시 정리 작업

app = FastAPI(
    title="리트의신 API",
    description="AI 기반 리트 모의고사/학습 플랫폼 API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 서비스 인스턴스
auth_service = AuthService()
diagnostic_service = DiagnosticService()
recommendation_service = RecommendationService()
analytics_service = AnalyticsService()
wrong_answer_service = WrongAnswerService()
learning_streak_service = LearningStreakService()

@app.get("/")
async def root():
    return {"message": "리트의신 API에 오신 것을 환영합니다!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}

# 인증 관련 엔드포인트
@app.post("/auth/register", response_model=UserResponse)
async def register(user_data: UserCreate):
    try:
        user = auth_service.register_user(user_data)
        return user
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/auth/login")
async def login(email: str = Form(...), password: str = Form(...)):
    try:
        token = auth_service.login_user(email, password)
        return {"access_token": token, "token_type": "bearer"}
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

@app.get("/auth/profile", response_model=UserResponse)
async def get_profile(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        user = auth_service.get_user_by_id(user_id)
        return user
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

# 진단 평가 관련 엔드포인트
@app.get("/diagnostic/questions")
async def get_diagnostic_questions():
    try:
        questions = diagnostic_service.get_diagnostic_questions()
        return {"questions": questions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/diagnostic/submit")
async def submit_diagnostic(answers: dict, credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        result = diagnostic_service.process_diagnostic(user_id, answers)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/diagnostic/result")
async def get_diagnostic_result(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        result = diagnostic_service.get_user_diagnostic_result(user_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 일일 모의고사 관련 엔드포인트
@app.get("/daily-test")
async def get_daily_test(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        daily_test = recommendation_service.get_today_daily_test(user_id)
        return daily_test
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/daily-test/submit")
async def submit_daily_test(answers: dict, credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        result = recommendation_service.process_daily_test_result(user_id, answers)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/daily-test/history")
async def get_daily_test_history(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        history = recommendation_service.get_user_daily_test_history(user_id)
        return {"history": history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 분석 관련 엔드포인트
@app.get("/analytics/dashboard")
async def get_dashboard(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        dashboard = analytics_service.get_user_dashboard(user_id)
        return dashboard
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/analytics/weekly-report")
async def get_weekly_report(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        report = analytics_service.generate_weekly_report(user_id)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 오답 노트 관련 엔드포인트
@app.get("/wrong-notes")
async def get_wrong_notes(
    subject: str = None,
    unit: str = None,
    difficulty_min: float = None,
    difficulty_max: float = None,
    mastered: bool = None,
    source_type: str = None,
    limit: int = 20,
    offset: int = 0,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """오답 노트 목록 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        from models.wrong_answer import WrongAnswerFilter
        
        filters = WrongAnswerFilter(
            subject=subject,
            unit=unit,
            difficulty_min=difficulty_min,
            difficulty_max=difficulty_max,
            mastered=mastered,
            source_type=source_type,
            limit=limit,
            offset=offset
        )
        
        wrong_notes = wrong_answer_service.get_wrong_answers(user_id, filters)
        return {"wrong_notes": wrong_notes}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/wrong-notes/{wrong_note_id}")
async def get_wrong_note_detail(
    wrong_note_id: int,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """특정 오답 노트 상세 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        wrong_note = wrong_answer_service.get_wrong_answer_by_id(user_id, wrong_note_id)
        
        if not wrong_note:
            raise HTTPException(status_code=404, detail="오답 노트를 찾을 수 없습니다.")
        
        return wrong_note
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/wrong-notes/{wrong_note_id}/review")
async def review_wrong_note(
    wrong_note_id: int,
    review_data: dict,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """오답 노트 문제 복습"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        from models.wrong_answer import WrongAnswerReviewCreate
        
        review_create = WrongAnswerReviewCreate(**review_data)
        review_result = wrong_answer_service.review_wrong_answer(user_id, wrong_note_id, review_create)
        
        return review_result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/wrong-notes/stats")
async def get_wrong_notes_stats(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """오답 노트 통계 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        stats = wrong_answer_service.get_wrong_answer_stats(user_id)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/wrong-notes/recommendations")
async def get_review_recommendations(
    limit: int = 10,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """복습 추천 문제 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        recommendations = wrong_answer_service.get_review_recommendations(user_id, limit)
        return {"recommendations": recommendations}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/wrong-notes/{wrong_note_id}")
async def delete_wrong_note(
    wrong_note_id: int,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """오답 노트 항목 삭제"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        success = wrong_answer_service.delete_wrong_answer(user_id, wrong_note_id)
        
        if not success:
            raise HTTPException(status_code=404, detail="오답 노트를 찾을 수 없습니다.")
        
        return {"message": "오답 노트가 삭제되었습니다."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 이용권 관련 엔드포인트
@app.get("/voucher/info")
async def get_voucher_info(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        voucher_info = voucher_service.get_user_voucher_info(user_id)
        return voucher_info
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/voucher/payment-history")
async def get_payment_history(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        payment_history = voucher_service.get_payment_history(user_id)
        return payment_history
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/voucher/payment-method")
async def get_payment_method(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        payment_method = voucher_service.get_payment_method(user_id)
        return {"payment_method": payment_method} if payment_method else {"payment_method": None}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/voucher/available")
async def get_available_vouchers(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        vouchers = voucher_service.get_available_vouchers()
        return vouchers
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/voucher/purchase")
async def purchase_voucher(voucher_id: int, credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        result = voucher_service.purchase_voucher(user_id, voucher_id, 1)  # payment_method_id는 임시로 1
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/voucher/cancel")
async def cancel_voucher(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        voucher_service = VoucherService(db)
        result = voucher_service.cancel_voucher(user_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 학습 스트릭 관련 엔드포인트
@app.get("/learning/streak")
async def get_learning_streak(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """학습 스트릭 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        streak = learning_streak_service.get_learning_streak(user_id)
        return streak
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/learning/activity")
async def record_learning_activity(
    activity_data: dict,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """학습 활동 기록"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        from models.learning_streak import DailyActivityCreate
        
        activity_create = DailyActivityCreate(**activity_data)
        result = learning_streak_service.record_daily_activity(user_id, activity_create)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/learning/activities")
async def get_daily_activities(
    days: int = 30,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """일일 학습 활동 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        activities = learning_streak_service.get_daily_activities(user_id, days)
        return {"activities": activities}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/learning/achievements")
async def get_achievements(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """성취 목록 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        achievements = learning_streak_service.get_user_achievements(user_id)
        return {"achievements": achievements}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/learning/stats")
async def get_learning_stats(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """종합 학습 통계 조회"""
    try:
        user_id = auth_service.verify_token(credentials.credentials)
        stats = learning_streak_service.get_learning_stats(user_id)
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 