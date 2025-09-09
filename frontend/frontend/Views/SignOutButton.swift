import SwiftUI

struct SignOutButton: View {
    // Keys you already use in LoginVM / router
    @AppStorage("auth.isAuthenticated") private var isAuthenticated = false
    @AppStorage("auth.displayName") private var displayName = ""
    @AppStorage("auth.rememberMe") private var rememberMe = false
    @AppStorage("auth.lastLoginAt") private var lastLoginAt = 0.0

    @State private var confirm = false

    var body: some View {
        Button(role: .destructive) {
            confirm = true
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Finora.surface, in: RoundedRectangle(cornerRadius: Finora.radiusMD))
        }
        .foregroundStyle(Finora.textPrimary)
        .confirmationDialog("Sign out of Pulse?", isPresented: $confirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                // Clear session
                isAuthenticated = false
                displayName = ""
                // Optional: also clear “remember me” state
                rememberMe = false
                lastLoginAt = 0
            }
            Button("Cancel", role: .cancel) {}
        }
        .accessibilityLabel("Sign Out")
    }
}
