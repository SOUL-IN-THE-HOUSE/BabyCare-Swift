# BabyCare-Swift

SwiftUI 기반 육아 기록 앱입니다.

## 주요 기능

- 최초 실행 시 아기 이름과 출생일 입력
- 기록, 분석, 설정 3탭 구성
- 모유, 분유, 이유식, 수면 기본 기록 버튼
- 기저귀, 목욕, 병원 등 기본 비활성 항목을 편집 화면에서 추가
- 제한 없는 커스텀 기록 항목 추가
- 현재 시간 기준 타임라인 기록과 메모
- 수량형 항목은 좌우 스와이프 다이얼로 `ml`, `g`, `분` 입력
- 오늘 기준 횟수, 총량, 마지막 기록 시간 요약
- 일간, 주간, 월간 분석 그래프
- 유료 클라우드 동기화 진입점

## 검증

```sh
xcodebuild -project BabyCareSwift.xcodeproj -scheme BabyCareSwift -destination 'platform=iOS Simulator,name=iPhone 16' build
```
