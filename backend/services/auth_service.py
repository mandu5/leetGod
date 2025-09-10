from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional
from models.database import SessionLocal
from models.user import User, UserCreate, UserResponse

# 비밀번호 해싱 설정
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT 설정
SECRET_KEY = "your-secret-key-here"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class AuthService:
    def __init__(self, db_session=None):
        self.db = db_session or SessionLocal()
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """비밀번호 검증"""
        return pwd_context.verify(plain_password, hashed_password)
    
    def get_password_hash(self, password: str) -> str:
        """비밀번호 해싱"""
        return pwd_context.hash(password)
    
    def create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None):
        """JWT 토큰 생성"""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=15)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt
    
    def verify_token(self, token: str) -> int:
        """JWT 토큰 검증"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id: int = payload.get("sub")
            if user_id is None:
                raise Exception("토큰이 유효하지 않습니다.")
            return user_id
        except JWTError:
            raise Exception("토큰이 유효하지 않습니다.")
    
    def register_user(self, user_data: UserCreate) -> UserResponse:
        """사용자 등록"""
        # 이메일 중복 확인
        existing_user = self.db.query(User).filter(User.email == user_data.email).first()
        if existing_user:
            raise Exception("이미 등록된 이메일입니다.")
        
        # 비밀번호 해싱
        hashed_password = self.get_password_hash(user_data.password)
        
        # 사용자 생성
        db_user = User(
            email=user_data.email,
            password_hash=hashed_password,
            name=user_data.name,
            grade=user_data.grade,
            target_grade=user_data.target_grade,
            study_time=user_data.study_time,
            learning_style=user_data.learning_style,
            diagnostic_completed=False
        )
        
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        
        return UserResponse(
            id=db_user.id,
            email=db_user.email,
            name=db_user.name,
            grade=db_user.grade,
            target_grade=db_user.target_grade,
            study_time=db_user.study_time,
            learning_style=db_user.learning_style,
            diagnostic_completed=db_user.diagnostic_completed,
            created_at=db_user.created_at,
            updated_at=db_user.updated_at
        )
    
    def login_user(self, email: str, password: str) -> str:
        """사용자 로그인"""
        # 사용자 조회
        user = self.db.query(User).filter(User.email == email).first()
        if not user:
            raise Exception("이메일 또는 비밀번호가 잘못되었습니다.")
        
        # 비밀번호 검증
        if not self.verify_password(password, user.password_hash):
            raise Exception("이메일 또는 비밀번호가 잘못되었습니다.")
        
        # JWT 토큰 생성
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = self.create_access_token(
            data={"sub": str(user.id)}, expires_delta=access_token_expires
        )
        
        return access_token
    
    def get_user_by_id(self, user_id: int) -> Optional[UserResponse]:
        """ID로 사용자 조회"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        return UserResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            grade=user.grade,
            target_grade=user.target_grade,
            study_time=user.study_time,
            learning_style=user.learning_style,
            diagnostic_completed=user.diagnostic_completed,
            created_at=user.created_at,
            updated_at=user.updated_at
        )
    
    def update_user_profile(self, user_id: int, **kwargs) -> Optional[UserResponse]:
        """사용자 프로필 업데이트"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        # 업데이트할 필드들
        updateable_fields = ['name', 'grade', 'target_grade', 'study_time', 'learning_style']
        
        for field, value in kwargs.items():
            if field in updateable_fields and hasattr(user, field):
                setattr(user, field, value)
        
        user.updated_at = datetime.now()
        self.db.commit()
        self.db.refresh(user)
        
        return UserResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            grade=user.grade,
            target_grade=user.target_grade,
            study_time=user.study_time,
            learning_style=user.learning_style,
            diagnostic_completed=user.diagnostic_completed,
            created_at=user.created_at,
            updated_at=user.updated_at
        ) 