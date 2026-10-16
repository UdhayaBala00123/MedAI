
import SwiftUI
import Combine

@MainActor
final class AuthSession: ObservableObject {

    static let shared = AuthSession()

    @Published var isLoggedIn: Bool = false

    private init() {
        // Check whether a token was saved previously.
        isLoggedIn = KeychainService.shared.getToken() != nil
    }

    // Call after a successful login.
    func loginSucceeded(token: String) {
        let saved = KeychainService.shared.saveToken(token)

        if saved {
            isLoggedIn = true
        } else {
            print("AuthSession: Failed to save access token.")
        }
    }

    // Call when the user explicitly logs out.
    func logout() {
        let deleted = KeychainService.shared.deleteToken()

        if deleted {
            isLoggedIn = false
        } else {
            print("AuthSession: Failed to delete access token.")
        }
    }
}

