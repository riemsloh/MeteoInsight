//
//  MeteoInsightApp.swift
//  MeteoInsight
//
//  Created by Olaf on 08.06.25.
//

import SwiftUI

@main
struct MeteoInsightApp: App {
    var body: some Scene {
        Settings {
            SettingsView()
        }
        WindowGroup {
            ContentView()
        }
    }
}
