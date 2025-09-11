from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

# SQLite 데이터베이스 URL (LEET 버전 기본값)
# 기존 mathgod.db로 남아 있던 데이터로 인해 혼선이 발생할 수 있어 기본 파일명을 변경합니다.
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./leetgod.db")

# SQLite 엔진 생성
engine = create_engine(
    DATABASE_URL, 
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base 클래스 생성
Base = declarative_base()

# 메타데이터
metadata = MetaData()

def init_db():
    """데이터베이스 초기화"""
    # 모든 모델을 import하여 테이블이 생성되도록 함
    from . import user, question, diagnostic, daily_test, voucher, wrong_answer, learning_streak
    
    # 모든 테이블 생성
    Base.metadata.create_all(bind=engine)
    print("✅ 데이터베이스가 초기화되었습니다.")

def get_db():
    """데이터베이스 세션 의존성"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# MongoDB 관련 코드 제거 (SQLite로 대체)
mongo_client = None
mongo_db = None

def get_mongo_db():
    """SQLite를 사용하므로 None 반환"""
    return None 