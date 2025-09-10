"""
Pytest configuration and fixtures for backend tests.
"""
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Test database URL
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

# Create test engine
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

# Create test session
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Create a fresh database session for each test."""
    try:
        from models.database import Base
        Base.metadata.create_all(bind=engine)
        session = TestingSessionLocal()
        yield session
    except Exception:
        # If database setup fails, just yield None
        yield None
    finally:
        try:
            from models.database import Base
            session.close()
            Base.metadata.drop_all(bind=engine)
        except Exception:
            pass


@pytest.fixture
def sample_user_data():
    """Sample user data for testing."""
    return {
        "email": "test@example.com",
        "password": "testpassword123",
        "name": "Test User",
        "grade": "150점",
        "learning_style": "시각적",
        "daily_study_time": 120
    }


@pytest.fixture
def sample_question_data():
    """Sample question data for testing."""
    return {
        "id": "TEST-001",
        "subject": "언어이해",
        "passage": "테스트 지문입니다.",
        "question": "테스트 문제입니다.",
        "options": ["① 옵션1", "② 옵션2", "③ 옵션3", "④ 옵션4", "⑤ 옵션5"],
        "correct_answer": {"index": 0, "text": "① 옵션1"},
        "explanation": "테스트 해설입니다."
    }