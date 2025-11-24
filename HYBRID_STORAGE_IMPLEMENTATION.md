# 하이브리드 저장소 구현 완료

## 변경 개요

A기기와 B기기에서 예약 데이터가 서로 영향을 주지 않도록 **하이브리드 저장 방식**으로 변경했습니다.

## 구현된 구조

```
[사용자 기기]
    │
    ├── [로컬 저장소] ← 빠른 로딩, 오프라인 가능
    │   └── UserDefaults에 JSON으로 저장
    │
    └── [Firebase Firestore] ← 병원 관리자용, 상태 동기화
        └── 문서명: "환자이름_timestamp_deviceId"
```

## 핵심 변경 사항

### 1. DeviceManager (NEW)
**파일**: `AIhealth/Services/Device/DeviceManager.swift`

- 기기별 고유 ID 생성 및 관리
- UserDefaults에 UUID 저장
- 앱 최초 실행 시 자동 생성

```swift
DeviceManager.shared.deviceId  // "A1B2C3D4-E5F6-..."
```

### 2. LocalReservationRepository (NEW)
**파일**: `AIhealth/Services/Repository/LocalReservationRepository.swift`

- 기기 로컬에 예약 데이터 저장
- UserDefaults + JSON 인코딩 사용
- 빠른 조회, 오프라인 작동 가능

**주요 메서드**:
- `saveReservation()` - 로컬 저장
- `getReservations()` - 로컬에서 불러오기
- `deleteReservation()` - 로컬 삭제
- `syncReservationStatus()` - Firebase 상태 동기화

### 3. FirebaseManager 업데이트
**파일**: `AIhealth/Services/Network/FirebaseManager.swift`

**변경 1: 문서명을 사용자 이름으로 변경**
```swift
// 이전: UUID만 사용
document("ABC-123-DEF")

// 현재: 이름_timestamp_deviceId
document("홍길동_1730265600_A1B2C3D4")
```

**변경 2: deviceId 필드 추가**
```swift
func saveReservation(_ reservation: Reservation) async throws -> String {
    // deviceId 자동 추가
    reservationData.deviceId = DeviceManager.shared.deviceId

    // 문서명 생성
    let documentName = "\(sanitizedName)_\(timestamp)_\(deviceIdSuffix)"
    db.collection("reservations").document(documentName).setData(...)
}
```

**변경 3: 기기별 필터링**
```swift
func getReservations() async throws -> [Reservation] {
    let deviceId = DeviceManager.shared.deviceId
    return try await db.collection("reservations")
        .whereField("deviceId", isEqualTo: deviceId)  // ← 핵심!
        .order(by: "createdAt", descending: true)
        .getDocuments()
}
```

**변경 4: 상태 조회 메서드 추가**
```swift
func getReservationStatus(id: String) async throws -> ReservationStatus? {
    // 예약 ID로 Firebase에서 최신 상태 조회
}
```

### 4. Reservation 모델 업데이트
**파일**: `AIhealth/Models/Reservation.swift`

```swift
struct Reservation: Identifiable, Codable {
    var id: String?
    var deviceId: String?  // ← 추가됨
    // ... 기존 필드들
}
```

### 5. ReservationRepository 업데이트
**파일**: `AIhealth/Services/Repository/ReservationRepository.swift`

**하이브리드 저장 전략**:

```swift
func saveReservation(_ reservation: Reservation) async throws -> String {
    // 1. Firebase에 먼저 저장 (병원 관리자용)
    let id = try await firebaseManager.saveReservation(reservation)

    // 2. 로컬에도 저장 (빠른 조회용)
    var localReservation = reservation
    localReservation.id = id
    localReservation.deviceId = DeviceManager.shared.deviceId
    try localRepo.saveReservation(localReservation)

    return id
}
```

```swift
func getReservations() throws -> [Reservation] {
    // 로컬에서만 조회 (즉시 로딩)
    return try localRepo.getReservations()
}
```

```swift
func syncReservationStatuses() async throws {
    let localReservations = try localRepo.getReservations()

    // 각 예약의 상태를 Firebase에서 확인
    for reservation in localReservations {
        if let firebaseStatus = try await firebaseManager.getReservationStatus(id: id) {
            // 상태가 변경되었으면 로컬 업데이트
            if firebaseStatus != reservation.status {
                try localRepo.syncReservationStatus(id: id, status: firebaseStatus)
            }
        }
    }
}
```

### 6. ReportViewModel 업데이트
**파일**: `AIhealth/ViewModels/ReportViewModel.swift`

```swift
func loadReservations() {
    // 1. 로컬에서 즉시 로딩 (빠름!)
    reservations = try reservationRepository.getReservations()
        .sorted { $0.createdAt > $1.createdAt }

    // 2. 백그라운드에서 상태 동기화
    Task {
        await syncReservationStatuses()
    }
}
```

## 동작 방식

### 예약 생성 시

1. **사용자가 예약 제출**
2. Firebase에 저장:
   ```
   문서명: "홍길동_1730265600_A1B2C3D4"
   필드: {
     id: "UUID-123",
     deviceId: "A1B2C3D4-...",
     patientName: "홍길동",
     status: "PENDING",
     ...
   }
   ```
3. 로컬에도 저장 (UserDefaults)
4. "내 기록" 화면에 즉시 표시

### 예약 목록 조회 시

1. **앱 시작 또는 화면 진입**
2. 로컬 저장소에서 즉시 로딩 (0.01초)
3. Firebase에서 상태 동기화 (백그라운드)
   - 병원에서 "대기" → "확정" 변경했으면
   - 로컬 데이터 업데이트
   - UI 자동 갱신

### 기기별 데이터 분리

```
[기기 A - deviceId: AAA111]
└── 로컬 저장소: 홍길동 예약만 보임
└── Firebase 조회: deviceId="AAA111" 필터링

[기기 B - deviceId: BBB222]
└── 로컬 저장소: 김철수 예약만 보임
└── Firebase 조회: deviceId="BBB222" 필터링

Firebase Firestore:
├── 홍길동_1730265600_AAA111 (기기 A 전용)
└── 김철수_1730265601_BBB222 (기기 B 전용)
```

## 장점

✅ **개인정보 보호**
- 각 기기는 자신의 예약만 볼 수 있음
- 다른 사람의 예약 정보 노출 차단

✅ **빠른 성능**
- 로컬 저장소에서 즉시 로딩
- 네트워크 없이도 조회 가능

✅ **오프라인 작동**
- 인터넷 없어도 "내 기록" 확인 가능
- 온라인 복구 시 자동 동기화

✅ **병원 관리 가능**
- Firebase Console에서 예약 상태 변경
- 문서명이 "이름_시간"으로 식별 쉬움
- 예: `홍길동_1730265600_A1B2C3D4`

✅ **상태 동기화**
- 백그라운드에서 자동으로 Firebase 상태 확인
- 병원의 변경사항 자동 반영

## Firebase Console에서 예약 관리하기

### 1. 예약 확정하기

```
Firestore Database → reservations 컬렉션
→ "홍길동_1730265600_A1B2C3D4" 문서 선택
→ status 필드를 "PENDING"에서 "CONFIRMED"로 변경
→ 저장
```

사용자 앱에서:
- 다음 화면 진입 시 자동으로 "대기" → "확정" 변경됨
- 배지 색상도 자동 변경 (주황 → 녹색)

### 2. 진료 완료 처리

```
status를 "COMPLETED"로 변경
```

### 3. 예약 취소

- 사용자가 앱에서 스와이프로 취소 가능
- 관리자도 Firebase에서 status를 "CANCELLED"로 변경 가능

## 테스트 방법

### 1. 두 기기에서 다른 예약 만들기

**기기 A (시뮬레이터)**:
1. 예약 화면에서 "홍길동" 이름으로 예약 제출
2. "내 기록"에서 확인

**기기 B (실제 기기 또는 다른 시뮬레이터)**:
1. 예약 화면에서 "김철수" 이름으로 예약 제출
2. "내 기록"에서 확인

**결과**:
- 기기 A: "홍길동" 예약만 표시
- 기기 B: "김철수" 예약만 표시
- Firebase: 두 예약 모두 저장됨 (문서명이 다름)

### 2. 상태 동기화 테스트

1. 기기 A에서 예약 생성 (상태: 대기)
2. Firebase Console에서 status를 "CONFIRMED"로 변경
3. 기기 A에서 앱 재실행 또는 "내 기록" 화면 재진입
4. 자동으로 "확정" 상태로 변경되는지 확인

### 3. 오프라인 테스트

1. 예약 생성
2. 비행기 모드 켜기
3. 앱 재실행
4. "내 기록"에서 예약 확인 가능 (로컬 저장소)

## 주의사항

⚠️ **기기 초기화 시 데이터 손실**
- UserDefaults에 저장되므로 앱 삭제 시 로컬 데이터 사라짐
- Firebase에는 남아있음
- 추후 로그인 시스템 도입 시 복구 가능하도록 업그레이드 필요

⚠️ **deviceId 변경 불가**
- 한 번 생성된 deviceId는 앱 삭제 전까지 유지됨
- 디버깅 시 `DeviceManager.shared.resetDeviceId()` 사용 가능

## 향후 개선 방안

1. **Core Data 도입**
   - UserDefaults 대신 Core Data 사용
   - 더 많은 데이터, 복잡한 쿼리 지원

2. **로그인 시스템**
   - Firebase Auth 도입
   - deviceId 대신 userId 사용
   - 기기 변경해도 데이터 동기화 가능

3. **푸시 알림**
   - 예약 상태 변경 시 알림
   - Firebase Cloud Messaging 사용

4. **자동 동기화**
   - 앱 활성화 시 자동 동기화
   - Background Fetch 활용

## 빌드 상태

✅ **BUILD SUCCEEDED**

모든 파일이 정상적으로 컴파일되었습니다.
