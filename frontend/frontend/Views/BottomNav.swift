//
//  BottomNav.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
        
            NewsFeedView()
                .tabItem { Label("News", systemImage: "newspaper.fill") }

            AlertsCenterView()
                .tabItem { Label("Alerts", systemImage: "bell.badge") }

            MicrosavingsView()
                .tabItem { Label("Save", systemImage: "target") }
        }
        .tint(Finora.primary)
    }
}

struct AlertsCenterView: View {
    var body: some View {
        Text("Alerts Center")
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Finora.background)
    }
}
struct MicrosavingsView: View {
    var body: some View {
        Text("Microsavings")
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Finora.background)
    }
}
