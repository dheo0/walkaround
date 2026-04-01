# 산책 🚶

주변 산책 코스 추천 및 커스텀 경로 생성 앱

## 기술 스택

| 구분 | 기술 |
|------|------|
| 프론트엔드 | Flutter |
| 백엔드 | Java Spring Boot 3 |
| 데이터베이스 | Supabase (PostgreSQL) |
| 인증 | Google 소셜 로그인 + JWT |
| 지도 | Google Maps SDK |

## 주요 기능

- **위치 기반 경로 탐색**: 현재 위치 반경 내 산책 코스 추천
- **커스텀 경로 생성**: 지도를 탭하여 나만의 산책 경로 생성
- **경로 공유**: 생성한 경로를 공개/비공개로 설정
- **북마크**: 마음에 드는 경로 저장
- **소셜 로그인**: Google 계정으로 간편 가입/로그인

## 프로젝트 구조

```
walkaround/
├── frontend/          # Flutter 앱
│   ├── lib/
│   │   ├── core/      # 네트워크, 라우터, 저장소
│   │   ├── features/  # auth, map, routes, profile
│   │   └── shared/    # 공통 위젯
│   └── pubspec.yaml
└── backend/           # Spring Boot API 서버
    ├── src/main/java/com/sancheck/
    │   ├── auth/      # JWT, 소셜 로그인
    │   ├── route/     # 경로 CRUD
    │   ├── user/      # 사용자 관리
    │   └── config/    # Security, CORS
    └── pom.xml
```

## 시작하기

### 사전 준비

1. **Supabase 프로젝트 생성**: [supabase.com](https://supabase.com)
2. **DB 초기화**: `backend/src/main/resources/schema.sql` Supabase SQL Editor에서 실행
3. **Google Cloud Console 설정**:
   - OAuth 2.0 클라이언트 ID 생성 (Android, iOS, Web 각각)
   - Maps SDK for Android / Maps SDK for iOS 활성화
   - Maps API 키 생성

### 백엔드 실행

```bash
cd backend

# 환경변수 설정 후 실행
./mvnw spring-boot:run -Dspring-boot.run.profiles=local \
  -Dspring-boot.run.jvmArguments="\
    -DSUPABASE_DB_URL=jdbc:postgresql://<host>:5432/postgres \
    -DSUPABASE_DB_USER=postgres \
    -DSUPABASE_DB_PASSWORD=<password> \
    -DJWT_SECRET=<base64-secret> \
    -DGOOGLE_CLIENT_ID=<client-id>"
```

### Flutter 앱 실행

```bash
cd frontend

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Android 에뮬레이터
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=GOOGLE_MAPS_API_KEY=<your-maps-key>
```

## API 엔드포인트

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| POST | `/api/auth/social-login` | 소셜 로그인 | 불필요 |
| GET | `/api/routes/nearby` | 주변 경로 조회 | 불필요 |
| GET | `/api/routes/{id}` | 경로 상세 | 불필요 |
| POST | `/api/routes` | 경로 생성 | 필요 |
| PUT | `/api/routes/{id}` | 경로 수정 | 필요 (본인) |
| DELETE | `/api/routes/{id}` | 경로 삭제 | 필요 (본인) |
| GET | `/api/users/me` | 내 프로필 | 필요 |
| GET | `/api/users/me/routes` | 내 경로 목록 | 필요 |
| GET | `/api/users/me/bookmarks` | 북마크 목록 | 필요 |
| POST | `/api/users/me/bookmarks/{routeId}` | 북마크 추가 | 필요 |
| DELETE | `/api/users/me/bookmarks/{routeId}` | 북마크 삭제 | 필요 |

## 인증 흐름

```
Flutter                    Spring Boot              Google / Supabase
  │                             │                         │
  │── Google Sign-In ──────────>│                         │
  │                             │── ID Token 검증 ───────>│
  │                             │<── 사용자 정보 ──────────│
  │                             │── 사용자 조회/생성 ────>│ (Supabase)
  │<── JWT (access + refresh) ──│                         │
  │                             │                         │
  │── API 요청 (Bearer JWT) ───>│                         │
  │<── 응답 ────────────────────│                         │
```

## DB 스키마

- `users` - 사용자 정보 (provider, provider_id로 소셜 계정 연동)
- `routes` - 산책 경로 (공개/비공개, 공공데이터/사용자 생성 구분)
- `route_waypoints` - 경로 좌표 포인트 (순서 있음)
- `bookmarks` - 사용자별 북마크