import SwiftUI

final class LoginVM: ObservableObject {
    @Published var email = "demo@finora.app"
    @Published var password = "password123"
    @Published var error: String?

    @AppStorage("auth.isAuthenticated") var isAuthenticated = false
    @AppStorage("auth.displayName") var displayName = ""

    private let auth = AuthService()

    func login() {
        do {
            let u = try auth.signIn(email: email, password: password)
            displayName = u.displayName
            isAuthenticated = true
            error = nil
        }
        catch let err {
            error = (err as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }

    }
}

struct LoginView: View {
    @StateObject private var vm = LoginVM()
    
    var body: some View {
        ZStack {
            Finora.background.ignoresSafeArea()
            VStack(spacing: 16) {
                // LOGO
                Image("PulseLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(.top, 8)
                    .accessibilityLabel("Pulse")
                
                Text("Welcome").font(.largeTitle.bold()).foregroundColor(Finora.textPrimary)
                
                VStack(spacing: 12) {
                    TextField("Email", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Finora.surface, in: RoundedRectangle(cornerRadius: Finora.radiusMD))
                    
                    SecureField("Password", text: $vm.password)
                        .padding()
                        .background(Finora.surface, in: RoundedRectangle(cornerRadius: Finora.radiusMD))
                }
                
                Button(action: {
                    vm.login()
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Finora.primary, in: RoundedRectangle(cornerRadius: Finora.radiusLG))
                .foregroundColor(.black)
                .font(.headline)
                
            }
        }
    }
}
