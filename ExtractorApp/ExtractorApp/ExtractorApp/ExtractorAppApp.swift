//
//  ExtractorAppApp.swift
//  ExtractorApp
//
//  Created by Eugenio de Frutos Sanchez on 11/06/2026.
//

import SwiftUI
import Sparkle

/// Controla qué canales de Sparkle puede ver esta instalación (Fase 16).
/// Sin opt-in (`betaChannelOptIn = false`), el conjunto es vacío y Sparkle
/// solo considera el canal por defecto/estable — mismo comportamiento que
/// antes de esta fase.
final class ExtractorUpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        UserDefaults.standard.bool(forKey: "betaChannelOptIn") ? ["beta"] : []
    }
}

@main
struct ExtractorAppApp: App {
    private let updaterDelegate = ExtractorUpdaterDelegate()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
        Settings {
            SettingsView()
        }
    }
}
