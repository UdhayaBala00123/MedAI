
import SwiftUI

struct ProfileView: View {
    @State private var user: User?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView("Loading profile...")
                } else if let user = user {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        let displayName = user.full_name.flatMap {
                            $0.isEmpty ? nil : $0
                        } ?? user.email

                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    AuthSession.shared.logout()
                } label: {
                    Label(
                        "Log Out",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .task {
                await loadProfile()
            }
        }
    }

    @MainActor
    private func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await UserService.shared.getCurrentUser()
        } catch {
            errorMessage = "Unable to load your profile. Please try again."
        }

        isLoading = false
    }
}

#Preview {
    ProfileView()
}
