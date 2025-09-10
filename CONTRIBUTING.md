# 🤝 기여 가이드

리트의신 프로젝트에 기여해주셔서 감사합니다! 이 문서는 프로젝트에 기여하는 방법을 안내합니다.

## 📋 목차

- [🎯 기여 방법](#-기여-방법)
- [🛠 개발 환경 설정](#-개발-환경-설정)
- [📝 코딩 스타일](#-코딩-스타일)
- [🧪 테스트](#-테스트)
- [📋 Pull Request](#-pull-request)
- [🐛 버그 리포트](#-버그-리포트)
- [💡 기능 제안](#-기능-제안)

## 🎯 기여 방법

### 🔍 기여할 수 있는 영역

- **🐛 버그 수정**: 버그를 발견하고 수정
- **✨ 새로운 기능**: 새로운 기능 개발
- **📚 문서화**: README, 코드 주석, API 문서 개선
- **🧪 테스트**: 테스트 코드 작성 및 개선
- **🎨 UI/UX**: 사용자 인터페이스 개선
- **⚡ 성능**: 성능 최적화
- **🔒 보안**: 보안 취약점 수정

### 🚀 빠른 시작

1. **Fork** the repository
2. **Clone** your fork
3. **Create** a feature branch
4. **Make** your changes
5. **Test** your changes
6. **Submit** a pull request

## 🛠 개발 환경 설정

자세한 설정 방법은 [SETUP_GUIDE.md](SETUP_GUIDE.md)를 참조하세요.

### 📋 요약

```bash
# 저장소 클론
git clone https://github.com/your-username/leetGod.git
cd leetGod

# 자동 설정
./setup.sh

# 또는 수동 설정
cd backend && pip install -r requirements.txt
cd frontend && flutter pub get
```

## 📝 코딩 스타일

### 🐍 Python (Backend)

- **PEP 8** 스타일 가이드 준수
- **Black** 코드 포맷터 사용
- **isort** import 정렬
- **mypy** 타입 힌트 사용

```bash
# 코드 포맷팅
black .
isort .

# 린팅
flake8 .
mypy .
```

### 📱 Dart (Frontend)

- **Effective Dart** 스타일 가이드 준수
- **dart format** 코드 포맷터 사용
- **flutter analyze** 정적 분석

```bash
# 코드 포맷팅
dart format .

# 분석
flutter analyze
```

### 📝 커밋 메시지

**Conventional Commits** 형식을 사용합니다:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 타입

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 스타일 변경
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 빌드 프로세스, 도구 변경

#### 예시

```
feat(auth): add JWT token refresh functionality

- Implement automatic token refresh
- Add refresh token storage
- Update authentication flow

Closes #123
```

## 🧪 테스트

### 🔬 Backend 테스트

```bash
cd backend

# 단위 테스트
pytest tests/unit/ -v

# 통합 테스트
pytest tests/integration/ -v

# 전체 테스트 (커버리지 포함)
pytest tests/ -v --cov=. --cov-report=html
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
```

### 📊 테스트 커버리지

- **Backend**: 80% 이상 유지
- **Frontend**: 70% 이상 유지

## 📋 Pull Request

### 🔍 PR 제출 전 체크리스트

- [ ] 코드가 코딩 스타일을 준수하는가?
- [ ] 테스트가 통과하는가?
- [ ] 테스트 커버리지가 유지되는가?
- [ ] 문서가 업데이트되었는가?
- [ ] 커밋 메시지가 Conventional Commits 형식을 따르는가?

### 📝 PR 템플릿

```markdown
## 📋 변경 사항

- [ ] 버그 수정
- [ ] 새로운 기능
- [ ] 문서 업데이트
- [ ] 테스트 추가/수정
- [ ] 리팩토링

## 🎯 설명

변경 사항에 대한 자세한 설명을 작성하세요.

## 🧪 테스트

- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 📸 스크린샷 (UI 변경시)

UI 변경이 있는 경우 스크린샷을 첨부하세요.

## 🔗 관련 이슈

Closes #123
```

### 🔄 PR 프로세스

1. **Draft PR** 생성
2. **코드 리뷰** 요청
3. **피드백** 반영
4. **승인** 후 머지

## 🐛 버그 리포트

### 📝 버그 리포트 템플릿

```markdown
## 🐛 버그 설명

버그에 대한 명확하고 간결한 설명을 작성하세요.

## 🔄 재현 단계

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## 🎯 예상 결과

예상했던 결과를 설명하세요.

## 📸 스크린샷

가능한 경우 스크린샷을 첨부하세요.

## 🖥 환경 정보

- OS: [e.g. macOS 12.0]
- Browser: [e.g. Chrome 91.0]
- Version: [e.g. 1.0.0]

## 📋 추가 정보

추가적인 컨텍스트나 정보를 제공하세요.
```

## 💡 기능 제안

### 📝 기능 제안 템플릿

```markdown
## 💡 기능 설명

제안하는 기능에 대한 명확하고 간결한 설명을 작성하세요.

## 🎯 문제점

이 기능이 해결하려는 문제점을 설명하세요.

## 💭 해결 방안

제안하는 해결 방안을 설명하세요.

## 🔄 대안

고려했던 다른 해결 방안이 있다면 설명하세요.

## 📋 추가 정보

추가적인 컨텍스트나 정보를 제공하세요.
```

## 🏷 라벨 시스템

### 🐛 버그 관련
- `bug`: 버그
- `critical`: 심각한 버그
- `security`: 보안 관련

### ✨ 기능 관련
- `enhancement`: 기능 개선
- `feature`: 새로운 기능
- `ui/ux`: UI/UX 관련

### 📚 문서 관련
- `documentation`: 문서
- `readme`: README
- `wiki`: Wiki

### 🧪 테스트 관련
- `test`: 테스트
- `coverage`: 커버리지
- `e2e`: E2E 테스트

## 🎯 기여자 가이드라인

### ✅ 좋은 기여

- 명확하고 간결한 코드
- 적절한 테스트 커버리지
- 문서화된 변경 사항
- 의미 있는 커밋 메시지

### ❌ 피해야 할 것

- 불필요한 복잡성
- 테스트 없는 코드
- 문서화되지 않은 변경 사항
- 의미 없는 커밋 메시지

## 🏆 기여자 인정

기여해주신 모든 분들께 감사드립니다! 기여자 목록은 [CONTRIBUTORS.md](CONTRIBUTORS.md)에서 확인할 수 있습니다.

## 📞 문의

기여와 관련하여 질문이 있으시면:

- **GitHub Issues**: [Issues](https://github.com/mandu5/leetGod/issues)
- **Discussions**: [Discussions](https://github.com/mandu5/leetGod/discussions)
- **Email**: [이메일 주소]

---

<div align="center">

**Thank you for contributing! 🚀**

</div>
