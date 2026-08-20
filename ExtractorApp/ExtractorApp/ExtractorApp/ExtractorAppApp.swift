//
//  ExtractorAppApp.swift
//  ExtractorApp
//
//  Created by Eugenio de Frutos Sanchez on 11/06/2026.
//

import SwiftUI
import Sparkle

@main
struct ExtractorAppApp: App {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
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
