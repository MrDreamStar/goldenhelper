//
//  ContentView.swift
//  GoldenHelper
//
//  主内容视图 - 导航容器
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(.stack)
        .accentColor(Theme.primaryColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
