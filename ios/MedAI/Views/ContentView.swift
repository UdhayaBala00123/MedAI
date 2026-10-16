import SwiftUI

struct ContentView: View {
    @StateObject private var session = AuthSession.shared

    var body: some View {
        Group {
            if session.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
