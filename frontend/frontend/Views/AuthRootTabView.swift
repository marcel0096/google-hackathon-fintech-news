import SwiftUI

struct AuthRootTabView: View {
    @AppStorage("auth.isAuthenticated") private var isAuthenticated: Bool = false
    @AppStorage("auth.displayName") private var displayName: String = ""

    var body: some View {
        Group {
            if isAuthenticated {
                BottomNav()   // your existing tabs
            } else {
                LoginView()   // mock login screen
            }
        }
        .background(Finora.background.ignoresSafeArea())
        .tint(Finora.primary)
    }
}
