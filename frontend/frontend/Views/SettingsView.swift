import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Finora.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.title.bold())
                    .foregroundStyle(Finora.textPrimary)

                // The reusable button you created in SignOutButton.swift
                SignOutButton()
            }
            .padding()
        }
    }
}
