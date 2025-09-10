#!/bin/bash

echo "📱 리트의신 Flutter 앱을 시작합니다..."

# Flutter 의존성 설치
echo "📦 Flutter 패키지를 설치합니다..."
cd frontend
flutter pub get

# 앱 실행
echo "🚀 Flutter 앱을 실행합니다..."
echo "앱이 실행되면 다음을 확인하세요:"
echo "- 백엔드 서버가 http://localhost:8000에서 실행 중인지 확인"
echo "- API 서비스의 baseUrl이 올바르게 설정되어 있는지 확인"
echo ""
echo "앱을 중지하려면 Ctrl+C를 누르세요."
echo ""

flutter run 