#!/bin/bash

echo "🚀 리트의신 백엔드 서버를 시작합니다..."

# 가상환경 활성화 (선택사항)
# source venv/bin/activate

# 의존성 설치
echo "📦 Python 패키지를 설치합니다..."
cd backend
pip install -r requirements.txt

# 데이터베이스 초기화
echo "🗄️ 데이터베이스를 초기화합니다..."
python init_data.py

# 서버 실행
echo "🌐 FastAPI 서버를 시작합니다..."
echo "서버 주소: http://localhost:8000"
echo "API 문서: http://localhost:8000/docs"
echo ""
echo "서버를 중지하려면 Ctrl+C를 누르세요."
echo ""

uvicorn main:app --reload --host 0.0.0.0 --port 8000 