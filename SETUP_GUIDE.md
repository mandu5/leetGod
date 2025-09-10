# 🚀 리트의신 개발 환경 설정 가이드

<div align="center">

![Setup Guide](https://img.shields.io/badge/Setup%20Guide-Complete-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker)

</div>

---

## 📋 목차

- [🎯 개요](#-개요)
- [📋 사전 요구사항](#-사전-요구사항)
- [🛠 설치 방법](#-설치-방법)
- [🐳 Docker 사용](#-docker-사용)
- [🔧 개발 환경 설정](#-개발-환경-설정)
- [🧪 테스트 환경](#-테스트-환경)
- [🐛 문제 해결](#-문제-해결)
- [📚 추가 리소스](#-추가-리소스)

---

## 🎯 개요

이 가이드는 **리트의신** 프로젝트의 개발 환경을 설정하는 방법을 단계별로 안내합니다. 
로컬 개발, Docker 사용, CI/CD 파이프라인 설정까지 모든 환경을 다룹니다.

### 🎯 지원 플랫폼
- ✅ **macOS** (10.15+)
- ✅ **Linux** (Ubuntu 18.04+)
- ✅ **Windows** (10+)

---

## 📋 사전 요구사항

### 🐍 Python 환경
```bash
# Python 3.8+ 설치 확인
python --version
# Python 3.8.0 이상이어야 합니다

# pip 업그레이드
python -m pip install --upgrade pip
```

### 📱 Flutter 환경
```bash
# Flutter 3.0+ 설치 확인
flutter --version
# Flutter 3.0.0 이상이어야 합니다

# Flutter doctor 실행
flutter doctor
```

### 🐙 Git 환경
```bash
# Git 설치 확인
git --version
# Git 2.20+ 권장

# Git 설정 (처음 사용시)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 🐳 Docker (선택사항)
```bash
# Docker 설치 확인
docker --version
docker-compose --version
```

---

## 🛠 설치 방법

### 1️⃣ 저장소 클론

```bash
# 저장소 클론
git clone https://github.com/mandu5/leetGod.git
cd leetGod

# 최신 변경사항 확인
git status
```

### 2️⃣ 자동 설정 스크립트 실행

```bash
# 실행 권한 부여
chmod +x setup.sh

# 자동 설정 실행
./setup.sh
```

### 3️⃣ 수동 설정 (고급 사용자)

#### 🖥 Backend 설정

```bash
# 백엔드 디렉토리로 이동
cd backend

# 가상환경 생성
python -m venv venv

# 가상환경 활성화
# macOS/Linux
source venv/bin/activate
# Windows
venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 환경 변수 설정
cp .env.example .env
# .env 파일을 편집하여 필요한 설정을 추가하세요

# 데이터베이스 초기화
python init_data.py

# 서버 실행
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

#### 📱 Frontend 설정

```bash
# 새 터미널에서 프론트엔드 디렉토리로 이동
cd frontend

# Flutter 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter packages pub run build_runner build

# 앱 실행
flutter run -d chrome --web-port=3001 --hot
```

---

## 🐳 Docker 사용

### 🚀 전체 스택 실행

```bash
# Docker Compose로 전체 스택 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 상태 확인
docker-compose ps
```

### 🔧 개별 서비스 실행

```bash
# 백엔드만 실행
docker-compose up backend

# 프론트엔드만 실행
docker-compose up frontend

# 데이터베이스만 실행
docker-compose up db
```

### 🛠 개발용 Docker 설정

```bash
# 개발용 Docker Compose 실행
docker-compose -f docker-compose.dev.yml up -d

# 볼륨 마운트로 실시간 코드 변경 반영
docker-compose -f docker-compose.dev.yml up --build
```

---

## 🔧 개발 환경 설정

### 🖥 Backend 개발

#### 📁 프로젝트 구조
```
backend/
├── main.py                 # FastAPI 애플리케이션 진입점
├── models/                 # SQLAlchemy 모델
├── services/               # 비즈니스 로직
├── routers/                # API 라우터
├── tests/                  # 테스트 코드
├── requirements.txt        # Python 의존성
├── requirements-dev.txt    # 개발용 의존성
└── .env.example           # 환경 변수 예시
```

#### 🔧 개발 도구 설정

```bash
# 개발용 의존성 설치
pip install -r requirements-dev.txt

# Pre-commit 훅 설정
pre-commit install

# 코드 포맷팅
black .
isort .

# 린팅
flake8 .
mypy .

# 테스트 실행
pytest tests/ -v --cov=.
```

#### 🌐 API 문서
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### 📱 Frontend 개발

#### 📁 프로젝트 구조
```
frontend/
├── lib/
│   ├── models/             # 데이터 모델
│   ├── providers/          # 상태 관리
│   ├── screens/            # UI 화면
│   ├── services/           # API 서비스
│   ├── utils/              # 유틸리티
│   ├── widgets/            # 재사용 가능한 위젯
│   └── constants/          # 상수 정의
├── assets/                 # 리소스 파일
├── test/                   # 테스트 코드
└── pubspec.yaml           # Flutter 의존성
```

#### 🔧 개발 도구 설정

```bash
# 코드 분석
flutter analyze

# 코드 포맷팅
dart format .

# 테스트 실행
flutter test

# 통합 테스트
flutter test integration_test/

# 빌드 테스트
flutter build web
flutter build apk
```

---

## 🧪 테스트 환경

### 🔬 Backend 테스트

```bash
cd backend

# 단위 테스트
pytest tests/unit/ -v

# 통합 테스트
pytest tests/integration/ -v

# 전체 테스트 (커버리지 포함)
pytest tests/ -v --cov=. --cov-report=html

# 테스트 커버리지 리포트 확인
open htmlcov/index.html
```

### 📱 Frontend 테스트

```bash
cd frontend

# 단위 테스트
flutter test test/

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter test integration_test/

# 테스트 커버리지
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 🚀 E2E 테스트

```bash
# 전체 E2E 테스트 실행
./scripts/run_e2e_tests.sh

# 특정 시나리오 테스트
./scripts/run_e2e_tests.sh --scenario=user_registration
```

---

## 🐛 문제 해결

### 🔧 일반적인 문제

#### 1. 포트 충돌
```bash
# 8000번 포트 사용 중인 프로세스 확인
lsof -i :8000
# 또는
netstat -tulpn | grep :8000

# 프로세스 종료
kill -9 <PID>
```

#### 2. Python 가상환경 문제
```bash
# 가상환경 재생성
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 3. Flutter 의존성 문제
```bash
# Flutter 캐시 정리
flutter clean
flutter pub get

# Flutter 업그레이드
flutter upgrade
```

#### 4. 데이터베이스 연결 오류
```bash
# SQLite 데이터베이스 재생성
rm -f backend/*.db
cd backend
python init_data.py
```

### 🔍 로그 확인

#### Backend 로그
```bash
# 실시간 로그 확인
tail -f backend/logs/app.log

# 에러 로그만 확인
grep "ERROR" backend/logs/app.log
```

#### Frontend 로그
```bash
# Flutter 로그 확인
flutter logs

# 특정 디바이스 로그
flutter logs -d chrome
```

### 🆘 추가 도움

문제가 지속되면 다음을 확인하세요:

1. **GitHub Issues**: [Issues](https://github.com/mandu5/leetGod/issues)
2. **Discussions**: [Discussions](https://github.com/mandu5/leetGod/discussions)
3. **Wiki**: [Wiki](https://github.com/mandu5/leetGod/wiki)

---

## 📚 추가 리소스

### 📖 문서
- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [Flutter 공식 문서](https://flutter.dev/docs)
- [SQLAlchemy 문서](https://docs.sqlalchemy.org/)

### 🎥 튜토리얼
- [FastAPI 튜토리얼](https://fastapi.tiangolo.com/tutorial/)
- [Flutter 튜토리얼](https://flutter.dev/docs/reference/tutorials)

### 🛠 도구
- [Postman](https://www.postman.com/) - API 테스트
- [VS Code](https://code.visualstudio.com/) - 코드 에디터
- [Android Studio](https://developer.android.com/studio) - Flutter 개발

---

## 🎯 다음 단계

환경 설정이 완료되면 다음을 진행하세요:

1. **코드 탐색**: [프로젝트 구조](#-프로젝트-구조) 섹션 참조
2. **첫 번째 기능 개발**: [기여 가이드](CONTRIBUTING.md) 참조
3. **테스트 작성**: [테스트 환경](#-테스트-환경) 섹션 참조
4. **PR 제출**: [기여하기](README.md#-기여하기) 섹션 참조

---

<div align="center">

**Happy Coding! 🚀**

문제가 있으시면 언제든 [Issues](https://github.com/mandu5/leetGod/issues)에 문의해주세요.

</div>