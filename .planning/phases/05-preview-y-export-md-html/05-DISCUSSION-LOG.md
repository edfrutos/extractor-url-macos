# Phase 5: Preview y Export MD/HTML — Discussion Log

**Date:** 2026-06-11
**Participants:** User + Claude
**Areas discussed:** 4 (WKWebView arquitectura, Markdown→HTML, Format selector, API export)

---

## Área 1: WKWebView — arquitectura

**Q1: ¿Cómo se estructura el NSViewRepresentable?**
- Opciones: Archivo separado `WebPreviewView.swift` / inline en ContentView
- Selección: **Archivo separado** (`Views/WebPreviewView.swift`)
- Razón: Más fácil de reutilizar en Phase 6 (PDF), ContentView no crece más

**Q2: ¿Cómo se señaliza contentReady?**
- Opciones: WKNavigationDelegate.webView(_:didFinish:) / evaluateJavaScript polling / Binding inyectado
- Selección: **WKNavigationDelegate.webView(_:didFinish:)**
- Razón: Método oficial Apple, sin polling frágil

**Q3: ¿Cómo llega contentReady al ViewModel?**
- Opciones: Binding<Bool> inyectado / NotificationCenter / closure inyectada
- Selección: **Binding<Bool> inyectado**
- Razón: Patrón estándar NSViewRepresentable, sin acoplamiento directo Coordinator→ViewModel

**Q4: ¿Cuándo se carga HTML en WKWebView?**
- Opciones: Al cambiar resultContent en updateNSView / con .onChange en ContentView
- Selección: **Al cambiar resultContent en updateNSView**
- Razón: SwiftUI rerender cycle ya gestiona la actualización; sin referencias externas al WKWebView

---

## Área 2: Markdown → HTML para preview

**Q1: ¿Cómo convierte Markdown a HTML para WKWebView?**
- Opciones: marked.js bundled / segunda llamada CLI / Down/cmark SPM
- Selección: **marked.js bundled en template HTML**
- Razón: Sin dependencias externas, funciona offline, un solo pipeline para los 3 tipos

**Q2: ¿WKWebView reemplaza ScrollView para todos los tipos?**
- Opciones: Sí, los 3 tipos / solo Markdown y HTML (texto mantiene ScrollView)
- Selección: **Sí, los 3 tipos**
- Razón: Un único componente, menos lógica condicional en ContentView

---

## Área 3: Format selector + botón Exportar

**Q1: ¿Dónde vive el selector de formato y botón Exportar?**
- Opciones: Nueva fila debajo del WKWebView / toolbar nativa / fila existente
- Selección: **Nueva HStack debajo del WKWebView**
- Razón: Acción junto al área de resultado; sin complejidad de window scene toolbar

**Q2: ¿Condición de disable del botón Exportar?**
- Opciones: `.disabled(!vm.contentReady)` / `.disabled(vm.isExtracting || !vm.contentReady)`
- Selección: **`.disabled(!vm.contentReady)`**
- Razón: Limpio, cubre todos los estados previos a DOM listo, satisface UI-03

**Q3: ¿El Picker muestra MD/HTML/PDF o solo MD/HTML?**
- Opciones: Los 3 (PDF deshabilitado) / solo MD/HTML en Phase 5
- Selección: **Los 3, PDF deshabilitado en Phase 5**
- Razón: El usuario ve el roadmap completo; la opción se activa en Phase 6

---

## Área 4: API de exportación

**Q1: ¿NSSavePanel o .fileExporter?**
- Opciones: NSSavePanel para ambos / SwiftUI .fileExporter para ambos
- Selección: **NSSavePanel para ambos**
- Razón: Consistente con Phase 6 (PDF también usa NSSavePanel + Data); sin FileDocument types

**Q2: ¿Cómo se llama NSSavePanel desde SwiftUI?**
- Opciones: async func en ViewModel con withCheckedContinuation / llamada directa en ContentView
- Selección: **async func en ViewModel con withCheckedContinuation**
- Razón: Patrón consistente con extract(); no bloquea hilo principal

**Q3: ¿Cómo se genera el HTML autocontenido?**
- Opciones: Template Swift con CSS hardcodeado / archivo HTML template en bundle
- Selección: **Template Swift con CSS hardcodeado en ViewModel**
- Razón: Sin asset adicional en el proyecto; CSS mínimo apple-system + dark mode + print

---

## Decisiones a Claude's Discretion

- Nombre sugerido para NSSavePanel (derivado de resultContent vs nombre fijo)
- Si WebPreviewView necesita @State o @StateObject para la instancia WKWebView
- Nombre exacto y visibilidad de `generateHTML` en ViewModel

---

## Ideas diferidas

- Export PDF — Phase 6 (opción visible pero deshabilitada en Phase 5)
- Toggle vista rendered/raw — nueva funcionalidad, fuera de scope v2.0
- Zoom/escala en WKWebView — innecesario para v2.0
