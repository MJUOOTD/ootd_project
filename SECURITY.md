# 보안 가이드

## 🔐 API 키 보안

### 절대 하지 말아야 할 것들

❌ **실제 API 키를 코드에 하드코딩**
```javascript
// 절대 이렇게 하지 마세요!
const API_KEY = "sk-1234567890abcdef";
```

❌ **실제 API 키를 Git에 커밋**
```bash
# .env 파일이 Git에 추가되는 것을 방지
git add .env  # 절대 하지 마세요!
```

❌ **API 키를 공개 저장소에 노출**
- GitHub, GitLab 등 공개 저장소에 API 키 업로드 금지
- 팀원들과 API 키를 직접 공유하지 마세요

### 올바른 방법

✅ **환경 변수 사용**
```bash
# .env 파일 생성 (Git에서 제외됨)
OPENWEATHER_API_KEY=your_actual_key_here
```

✅ **.gitignore 설정**
```
.env
.env.local
.env.*.local
```

✅ **팀원과 공유할 때는 .env.example 사용**
```bash
# .env.example 파일 (실제 키 없이 템플릿만)
OPENWEATHER_API_KEY=your_api_key_here
```

## 🛡️ 현재 프로젝트 보안 상태

### ✅ 보안 조치 완료
- `.gitignore`에 `.env` 파일 제외 설정
- API 키 없이도 서버 정상 작동 (Mock 데이터 사용)
- 환경 변수 템플릿 제공 (`.env.example`)

### 🔍 API 키 확인 방법
```bash
# 현재 사용 중인 API 키 확인 (개발자용)
echo $OPENWEATHER_API_KEY

# 서버 로그에서 API 사용 상태 확인
# [OpenWeatherMap] API key not found, using mock data
```

## 🚨 API 키 노출 시 대응 방법

1. **즉시 API 키 재발급**
   - OpenWeatherMap: https://openweathermap.org/api
   - 기존 키 비활성화

2. **Git 히스토리에서 제거**
   ```bash
   # Git 히스토리에서 .env 파일 제거
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch .env' \
   --prune-empty --tag-name-filter cat -- --all
   ```

3. **팀원들에게 알림**
   - 노출된 API 키 사용 중단 요청
   - 새로운 API 키 공유

## 📋 체크리스트

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는가?
- [ ] 실제 API 키가 코드에 하드코딩되어 있지 않은가?
- [ ] 팀원들이 `.env.example`을 사용하고 있는가?
- [ ] API 키가 공개 저장소에 노출되지 않았는가?
- [ ] 정기적으로 API 키를 갱신하고 있는가?

## 📞 문의사항

보안 관련 문의사항이 있으시면 개발팀에 연락해주세요.
