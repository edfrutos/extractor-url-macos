//
//  CheckForUpdatesView.swift
//  ExtractorApp
//

import Combine
import SwiftUI
import Sparkle

/// Publica cuándo el usuario puede pulsar "Buscar actualizaciones…"
/// (Sparkle deshabilita canCheckForUpdates mientras una comprobación
/// ya está en curso o si el updater no está listo).
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

/// Vista intermedia necesaria para que el estado disabled del NSMenuItem
/// se refleje correctamente (patrón oficial de Sparkle para SwiftUI).
struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        Button("Buscar actualizaciones…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}
