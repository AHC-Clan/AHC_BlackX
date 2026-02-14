# AHC_BlackX

Arma 3 서버용 원격 키 인증 보안 시스템입니다.  
GitHub에 저장된 인증 키와 DLL에 내장된 키를 비교하여, 무단 사용 시 클라이언트를 차단합니다.

---

## 개요

AHC_BlackX는 Arma 3의 Extension(DLL) 인터페이스를 활용한 애드온 인증 시스템입니다.

| 구성 요소 | 설명 |
|-----------|------|
| **AHC_BlackX.dll** | C++ DLL — GitHub에서 원격 키를 가져와 내장 키와 대조 |
| **abx_init.sqf** | SQF 스크립트 — DLL 호출 후 인증 실패 시 화면 잠금 |
| **AHC_BlackX.txt** | 현재 활성 인증 키 파일 (GitHub에 push되어 원격 검증용으로 사용) |

### 동작 흐름

```
[Arma 3 클라이언트]
      │
      ▼
  abx_init.sqf 실행
      │
      ▼
  AHC_BlackX.dll "auth" 호출
      │
      ├── GitHub에서 AHC_BlackX.txt 원격 키 fetch (HTTPS)
      ├── 내장 EXPECTED_KEY와 비교
      │
      ├─ 일치 → "1" 반환 → 정상 진행
      └─ 불일치 → "0" 반환 → 화면 잠금 & 사용자 정보 표시
```

---

## 프로젝트 구조

```
AHC_BlackX/
├── README.md                 # 이 문서
├── AHC_BlackX.txt            # 현재 인증 키
├── build.bat                 # DLL 빌드 스크립트
├── GenerateNewKey.bat        # 키 갱신 도구 (Manual / Auto)
├── git.bat                   # Git 커밋/푸시 관리 도구
├── renew_key.ps1             # 키 생성 & 적용 PowerShell 스크립트
│
├── addon/
│   ├── abx_init.sqf          # 인증 SQF 스크립트
│   └── SAMPLE_config.cpp     # config.cpp 연동 예시
│
└── dll/
    ├── AHC_BlackX.vcxproj    # Visual Studio 프로젝트
    └── src/
        └── main.cpp          # DLL 소스코드
```

---

## 요구 사항

- **OS**: Windows 10 이상
- **Visual Studio**: 2019 이상 (C++ 데스크톱 개발 워크로드 필요)
- **Git**: 커맨드라인 사용 가능해야 함
- **PowerShell**: 5.1 이상

---

## 빌드 방법

### DLL 빌드

```bat
build.bat
```

Visual Studio의 MSBuild를 자동 탐지하여 `Release|x64` 설정으로 DLL을 빌드합니다.  
빌드 완료 시 프로젝트 루트에 `AHC_BlackX.dll`이 생성됩니다.

### 키 갱신 + 빌드

```bat
GenerateNewKey.bat
```

실행 후 아래 모드를 선택합니다:

| 모드 | 설명 |
|------|------|
| `[0] Manual` | 키 변경 + DLL 빌드만 수행. Git 작업은 수동으로 해야 합니다. |
| `[1] Auto` | 키 변경 + Git commit/push + DLL 빌드를 한 번에 수행합니다. |

키 갱신 시 다음 파일이 자동 업데이트됩니다:
- `AHC_BlackX.txt` — 원격 검증용 키
- `dll/src/main.cpp` — DLL 내장 `EXPECTED_KEY`

---

## 배포

빌드된 `AHC_BlackX.dll`을 아래 위치 중 하나에 배치합니다:

- `@AHC_Addon\` 루트 폴더
- Arma 3 게임 루트 디렉토리

---

## 애드온 연동

### 방식 A — config.cpp에서 호출

```cpp
class Extended_PostInit_EventHandlers {
    class 내_애드온_이름 {
        init = "call compile preprocessFileLineNumbers '\내_애드온_이름\abx_init.sqf'";
    };
};
```

### 방식 B — XEH_postInit.sqf에서 호출

```sqf
call compile preprocessFileLineNumbers "\내_애드온_이름\abx_init.sqf";
```

> `내_애드온_이름` 부분을 실제 애드온 폴더명으로 교체하세요.

---

## Git 관리

```bat
git.bat
```

| 옵션 | 설명 |
|------|------|
| `[0]` | 전체 파일 커밋 |
| `[1]` | AHC_BlackX.txt 제외하고 커밋 |
| `[2]` | AHC_BlackX.txt만 커밋 |
| `[3]` | 로컬 변경 사항 버리고 원격으로 리셋 |

---

## 보안 참고 사항

- 인증 키는 GitHub raw URL을 통해 HTTPS로 가져옵니다.
- 키가 외부에 노출될 경우 `GenerateNewKey.bat`으로 즉시 교체하세요.
- `AHC_BlackX.txt`는 반드시 `main` 브랜치에 push되어 있어야 원격 검증이 동작합니다.

---

## 라이선스

이 프로젝트는 AHC 클랜 내부 사용을 위한 것입니다.
