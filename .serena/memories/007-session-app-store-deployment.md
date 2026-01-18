# App Store 배포 프로세스 세션

## 날짜
2026-01-18

## 세션 요약
사용자가 simple_memo Flutter 앱을 App Store에 배포하는 방법을 문의함.

## 현재 앱 상태
- **프레임워크:** Flutter
- **앱 이름:** simple_memo (간단한 메모 앱)
- **버전:** 1.0.0+1
- **Bundle ID:** com.example.simpleMemo (변경 필요)
- **주요 의존성:** shared_preferences, uuid

## 제공한 배포 가이드

### 필수 준비 사항
1. Apple Developer Program 가입 ($99/년)
2. Bundle Identifier 고유값으로 변경
3. 앱 아이콘 1024x1024 PNG 준비
4. 스크린샷 준비 (iPhone 6.7", 6.5")
5. 개인정보 처리방침 URL 필요

### 배포 단계
1. App Store Connect에서 앱 생성
2. `flutter build ipa` 로 릴리스 빌드
3. Xcode Organizer 또는 Transporter로 업로드
4. 앱 정보 입력 및 심사 제출
5. 심사 대기 (24-48시간)

## 다음 단계
사용자가 어떤 단계부터 도움이 필요한지 확인 대기 중

## 체크리스트 상태
- [ ] Apple Developer Program 가입
- [ ] Bundle ID 변경
- [ ] 앱 아이콘 준비
- [ ] 스크린샷 준비
- [ ] 개인정보 처리방침 URL
- [ ] App Store Connect 앱 생성
