import Foundation

struct User { let email: String; let password: String; let displayName: String }

final class AuthService {
    private let users: [String: User] = [
        "demo@finora.app": .init(email: "demo@finora.app", password: "password123", displayName: "Finora Demo")
    ]

    enum AuthError: LocalizedError {
        case invalidCredentials
        var errorDescription: String? { "Invalid email or password." }
    }

    func signIn(email: String, password: String) throws -> User {
        guard let u = users[email.lowercased()], u.password == password else {
            throw AuthError.invalidCredentials
        }
        return u
    }
}
