
import Foundation

final class UserService {

    static let shared = UserService()

    private init() {}

    func getCurrentUser() async throws -> User {
        try await APIService.shared.request(
            "/api/auth/me",
            authenticated: true
        )
    }
}
