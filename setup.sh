#!/bin/bash

echo "🎯 수학의 신 프로젝트 설정을 시작합니다..."
echo ""

# 스크립트 실행 권한 부여
echo "🔧 스크립트 실행 권한을 설정합니다..."
chmod +x run_backend.sh
chmod +x run_frontend.sh

# 백엔드 설정
echo "🐍 Python 백엔드를 설정합니다..."
cd backend

# 가상환경 생성 (선택사항)
echo "가상환경을 생성하시겠습니까? (y/n)"
read -r create_venv
if [ "$create_venv" = "y" ]; then
    python -m venv venv
    echo "가상환경이 생성되었습니다. 활성화하려면: source venv/bin/activate"
fi

# 의존성 설치
echo "📦 Python 패키지를 설치합니다..."
pip install -r requirements.txt

# 데이터베이스 초기화
echo "🗄️ 데이터베이스를 초기화합니다..."
python init_data.py

cd ..

# Flutter 설정
echo "📱 Flutter 앱을 설정합니다..."
cd frontend

# Flutter 의존성 설치
echo "📦 Flutter 패키지를 설치합니다..."
flutter pub get

cd ..

echo ""
echo "✅ 수학의 신 프로젝트 설정이 완료되었습니다!"
echo ""
echo "📋 다음 단계:"
echo "1. 백엔드 서버 실행: ./run_backend.sh"
echo "2. Flutter 앱 실행: ./run_frontend.sh"
echo ""
echo "🌐 API 문서: http://localhost:8000/docs"
echo "📱 앱 테스트 계정:"
echo "   - 이메일: student1@example.com"
echo "   - 비밀번호: password123"
echo ""
echo "🚀 개발을 시작하세요!" 