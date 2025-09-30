# 📅 OOTD 앱 – 개발 & 발표 준비 Gantt Chart (업데이트1 버전)

```mermaid
gantt
    title OOTD 앱 개발 & 발표 준비 일정
    dateFormat  YYYY-MM-DD
    axisFormat  %m/%d

    section 문서화 & 디자인
    요구사항/명세서 정리 :done,    des1, 2025-09-12, 2025-09-16
    UI/UX 디자인 (피그마 시안) :done, des2, 2025-09-12, 2025-09-16

    section 개발 환경 세팅
    Flutter/Firebase/Git 세팅 :done, des3, 2025-09-17, 2025-09-19

    section 온보딩
    회원가입/로그인/프로필 설정 :des4, 2025-09-20, 3d

    section 날씨/추천
    위치 권한 & 날씨 API 연동 :des5, 2025-09-23, 1d
    옷차림 추천 알고리즘 (v1) :des6, 2025-09-24, 1d
    홈 화면 통합 (날씨+추천+메시지) :des7, 2025-09-25, 1d

    section 추가 모듈
    저장/검색/설정 기본 모듈 :des8, 2025-09-26, 1d
    피드백 시스템 (추웠다/더웠다 반영) :des9, 2025-09-27, 0.5d

    section QA & 발표
    통합 테스트 & 리허설 :des10, 2025-09-27, 1.5d
    발표 자료 제작 (슬라이드/시연) :des11, 2025-09-27, 2025-09-29

    section 발표
    최종 발표 :milestone, m1, 2025-10-01, 0d
