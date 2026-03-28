//
//  GoldenHelperApp.swift
//  GoldenHelper
//
//  黄金助手 - iOS原生版本
//  投资收益计算工具
//

import SwiftUI

@main
struct GoldenHelperApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}
