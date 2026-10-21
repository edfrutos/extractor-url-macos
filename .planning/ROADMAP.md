


## v11.0 — Mac App Store

## Overview

Publicar ExtractorApp en la Mac App Store **sin retirar** la distribución
Developer ID + Sparkle de GitHub. La variante App Store corre en App
Sandbox, no incluye Sparkle, runtime updater ni Chromium, y renderiza
JavaScript con `WKWebView`. Gratuita. Research: `.planning/research/APPSTORE.md`.

El riesgo dominante (Python embebido bajo sandbox + validación de App
Store Connect) se ataca primero con un spike: si falla, el resto del
milestone se replantea antes de invertir en él.

### Checklist v11.0

- [x] **Phase 24: Spike — Python embebido bajo App Sandbox** - Demostrar extracción estática con sandbox y validación de App Store Connect.
- [x] **Phase 25: Variante de build App Store** - Configuración/esquema propios con flag; exclusiones, entitlements y manifiesto de privacidad.
- [ ] **Phase 26: Renderizado JavaScript con WKWebView** - HTML renderizado por `WKWebView` → Python, con la heurística actual.
- [ ] **Phase 27: Funciones de la app bajo sandbox** - Export, «Abrir HTML…», historial, portapapeles y errores bajo sandbox.
- [ ] **Phase 28: App Store Connect y envío** - Certificados, ficha, privacidad, script de subida, TestFlight, aprobación.

### Phase 24: Spike — Python embebido bajo App Sandbox

**Goal**: Probar, con el menor cambio posible, que el intérprete Python embebido funciona bajo App Sandbox y que App Store Connect acepta el paquete.
**Depends on**: Phase 08 (runtime embebido), Phase 13 (pipeline de firma)
**Requirements**: SBX-01, SBX-02, SBX-03, SBX-04
**Plans**: 24-01-PLAN.md (spike sin tocar Xcode: `scripts/spike-appstore.sh`) + CHECKPOINT-HUMANO.md
**Success Criteria** (what must be TRUE):

  1. Un build con sandbox extrae una URL estática con el Python embebido en un Mac real.
  2. La ubicación del código nativo de Python queda decidida y documentada con evidencia (validación real, no suposición).
  3. El bundle no contiene `_tkinter` ni Tcl/Tk.
  4. App Store Connect valida el paquete sin errores (sin enviarlo a revisión).

**UI hint**: no

### Phase 25: Variante de build App Store

**Goal**: Mantener dos variantes desde el mismo código: Developer ID (sin cambios) y App Store (sandbox, sin Sparkle/runtime updater/Chromium).
**Depends on**: Phase 24
**Requirements**: MASBUILD-01, MASBUILD-02, MASBUILD-03, MASBUILD-04, MASBUILD-05
**Plans**: 25-01-PLAN.md (código `#if APPSTORE`, `bundle-python.sh` por variante, entitlements, Info.plist, manifiesto) → 25-02-PLAN.md (target y esquema `ExtractorApp AppStore`, `package-appstore.sh`) + CHECKPOINT-HUMANO.md
**Success Criteria** (what must be TRUE):

  1. `scripts/release-macos.sh` sigue produciendo el release Developer ID igual que en v2.3.
  2. La variante App Store compila sin Sparkle, `RuntimeUpdater`, Chromium ni rutas externas en Ajustes.
  3. Entitlements y `PrivacyInfo.xcprivacy` revisados contra la documentación vigente.
  4. Ninguna escritura dentro del bundle durante una extracción.

**UI hint**: yes

### Phase 26: Renderizado JavaScript con WKWebView

**Goal**: Recuperar la extracción de páginas con JavaScript en la variante App Store usando el motor del sistema.
**Depends on**: Phase 25
**Requirements**: WKJS-01, WKJS-02, WKJS-03, WKJS-04
**Success Criteria** (what must be TRUE):

  1. La CLI acepta HTML renderizado + URL de origen, con tests (pytest).
  2. Una SPA que hoy necesita Chromium se extrae en la variante App Store vía `WKWebView`.
  3. Un fallo o timeout de renderizado degrada a HTML estático con aviso.

**UI hint**: no

### Phase 27: Funciones de la app bajo sandbox

**Goal**: Que la variante App Store haga todo lo que hace hoy la app, dentro del sandbox.
**Depends on**: Phase 25
**Requirements**: SBXFEAT-01, SBXFEAT-02, SBXFEAT-03, SBXFEAT-04, SBXFEAT-05
**Success Criteria** (what must be TRUE):

  1. Export MD/HTML/PDF, «Abrir HTML…», historial y portapapeles funcionan en un Mac real con sandbox.
  2. Los mensajes de error coinciden con los de la variante Developer ID.

**UI hint**: yes

### Phase 28: App Store Connect y envío

**Goal**: Publicar la variante App Store.
**Depends on**: Phase 26, Phase 27
**Requirements**: STORE-01, STORE-02, STORE-03, STORE-04, STORE-05, STORE-06
**Success Criteria** (what must be TRUE):

  1. Certificados, perfil y registro de la app listos.
  2. Ficha en español completa, con política de privacidad y soporte publicados.
  3. Subida reproducible con un script documentado en `RELEASING.md`.
  4. Build probado en TestFlight y app aprobada y publicada.

**UI hint**: no

### Estado v11.0

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 24. Spike — Python embebido bajo App Sandbox | 1/1 | Complete | 2026-10-20 |
| 25. Variante de build App Store | 2/2 | Complete | 2026-10-21 |
| 26. Renderizado JavaScript con WKWebView | 0 | Not started | - |
| 27. Funciones de la app bajo sandbox | 0 | Not started | - |
| 28. App Store Connect y envío | 0 | Not started | - |
