---
phase: 07-universal-binary
plan: 01
subsystem: build-configuration
tags:
  - xcode-build-settings
  - entitlements
  - arm64-x86_64
  - deployment-target
dependency_graph:
  requires:
    - APP-04: "MACOSX_DEPLOYMENT_TARGET = 13.0"
    - APP-05: "hardened-runtime configuration"
  provides:
    - "project.pbxproj with correct MACOSX_DEPLOYMENT_TARGET (13.0) at project level"
    - "ARCHS = arm64 x86_64 explicitly set for ExtractorApp target"
    - "ExtractorApp.entitlements declares hardened-runtime = true"
  affects:
    - "Phase 07-02: Universal Binary Testing and Verification"
tech_stack:
  added: []
  patterns:
    - "Xcode build settings management (pbxproj)"
    - "macOS entitlements plist configuration"
key_files:
  created: []
  modified:
    - "ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj"
    - "ExtractorApp/ExtractorApp/ExtractorApp/ExtractorApp.entitlements"
decisions:
  - "MACOSX_DEPLOYMENT_TARGET = 13.0 at project level (not 26.5 which is Xcode version)"
  - "ARCHS = \"arm64 x86_64\" added to target-level Debug and Release configurations only (not project or test targets)"
  - "hardened-runtime explicitly declared in .entitlements for coherence with ENABLE_HARDENED_RUNTIME = YES in build settings"
  - "app-sandbox remains false to allow Process() calls with arbitrary paths (Python bridge requirement)"
metrics:
  duration: "5 min"
  completed: "2026-06-13"
  tasks: 4
---

# Phase 07 Plan 01: Build Settings Configuration Summary

**One-liner:** Corregir MACOSX_DEPLOYMENT_TARGET a 13.0 (desde 26.5), definir ARCHS = arm64 x86_64 para universal binary, y añadir hardened-runtime = true a entitlements.

## Completed Tasks

| Task | Name | Commit | Files Modified |
|------|------|--------|-----------------|
| 1 | Corregir MACOSX_DEPLOYMENT_TARGET de 26.5 a 13.0 | 29426d3 | project.pbxproj |
| 2 | Definir ARCHS = arm64 x86_64 en build settings | 980d88d | project.pbxproj |
| 3 | Añadir hardened-runtime = true a .entitlements | cf54f12 | ExtractorApp.entitlements |
| 4 | Compilar y verificar sin errores | (verification only) | — |

## Changes Made

### Task 1: Fix MACOSX_DEPLOYMENT_TARGET

**Issue:** El archivo project.pbxproj tenía MACOSX_DEPLOYMENT_TARGET = 26.5 en las configuraciones Debug y Release a nivel de proyecto. Este valor (26.5) es la versión de Xcode, no una versión válida de macOS.

**Resolution:**
- Línea 248 (Debug, project-level): 26.5 → 13.0
- Línea 305 (Release, project-level): 26.5 → 13.0
- Las configuraciones del target ExtractorApp (líneas 333, 367) y test target (líneas 393, 416) ya estaban correctas en 13.5

**Verification:**
```bash
grep -c "MACOSX_DEPLOYMENT_TARGET = 13.0" ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj
# Output: 2 (project-level settings corrected)

grep "MACOSX_DEPLOYMENT_TARGET = 26.5" ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj | wc -l
# Output: 0 (no remaining invalid values)
```

### Task 2: Define ARCHS = arm64 x86_64

**Issue:** El proyecto no especificaba explícitamente las arquitecturas para compilación, lo que podría resultar en un build solo arm64 en algunos contextos.

**Resolution:**
- Añadido `ARCHS = "arm64 x86_64";` en la configuración Debug del target ExtractorApp
- Añadido `ARCHS = "arm64 x86_64";` en la configuración Release del target ExtractorApp
- No se modificaron las configuraciones project-level ni test target (los defaults de Xcode son suficientes)

**Verification:**
```bash
grep "ARCHS = " ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj | grep -c "arm64 x86_64"
# Output: 2 (Debug and Release target configurations set correctly)
```

### Task 3: Add Hardened-Runtime to Entitlements

**Issue:** El archivo .entitlements tenía solo app-sandbox = false. Para coherencia con ENABLE_HARDENED_RUNTIME = YES en build settings y para cumplir APP-05, se requería añadir hardened-runtime = true de forma explícita.

**Resolution:**
- Añadido bloque:
  ```xml
  <!-- Hardened Runtime ON: mitigación contra ejecución de código memoria sin autorización -->
  <key>com.apple.security.hardened-runtime</key>
  <true/>
  ```
- Ubicación: después de app-sandbox y antes del comentario about allow-unsigned-executable-memory
- Mantiene comentario sobre allow-unsigned-executable-memory (descommentable si Python trafilatura requiere JIT)

**Verification:**
```bash
grep -c "com.apple.security.hardened-runtime" ExtractorApp/ExtractorApp/ExtractorApp/ExtractorApp.entitlements
# Output: 1
```

### Task 4: Build Verification

**Action:** Compilación del proyecto en configuración Release.

**Command:**
```bash
cd /Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url/ExtractorApp/ExtractorApp
xcodebuild build -scheme ExtractorApp -configuration Release
```

**Result:** `** BUILD SUCCEEDED **`

**Verification:**
- Ningún error de build settings (MACOSX_DEPLOYMENT_TARGET o ARCHS)
- Ningún warning de configuración (solo warning estándar de selección de destino)
- Binario Release compilado correctamente en `/Users/edefrutos/Library/Developer/Xcode/DerivedData/ExtractorApp-cnntupvmrfcezodcjxwheixutmbm/Build/Products/Release/ExtractorApp.app`

## Threat Model Compliance

| Threat ID | Category | Disposition | Mitigation Applied |
|-----------|----------|-------------|-------------------|
| T-07-01 | Tampering (Entitlements) | mitigate | ✅ hardened-runtime = true explicitly declared |
| T-07-02 | Tampering (Build settings) | mitigate | ✅ Validated ARCHS and MACOSX_DEPLOYMENT_TARGET via grep; no hand-crafted or incomplete values |
| T-07-03 | Integrity (Universal binary) | mitigate | ⏳ lipo validation deferred to Phase 07-02 Task 5 |

## Known Stubs

None. All configuration is complete and functional.

## Self-Check: PASSED

**File existence:**
```bash
[ -f ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj ] && echo "FOUND" || echo "MISSING"
# Output: FOUND

[ -f ExtractorApp/ExtractorApp/ExtractorApp/ExtractorApp.entitlements ] && echo "FOUND" || echo "MISSING"
# Output: FOUND
```

**Commit verification:**
```bash
git log --oneline | grep -E "29426d3|980d88d|cf54f12"
# Output:
# cf54f12 feat(07-01): añadir hardened-runtime = true a archivo .entitlements
# 980d88d feat(07-01): definir ARCHS = arm64 x86_64 en build settings del target ExtractorApp
# 29426d3 fix(07-01): corregir MACOSX_DEPLOYMENT_TARGET de 26.5 a 13.0 en configuraciones a nivel de proyecto
```

**Build success:**
```bash
xcodebuild build -scheme ExtractorApp -configuration Release 2>&1 | tail -1
# Output: ** BUILD SUCCEEDED **
```

All requirements met. Phase 07-01 complete.
