
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // App Header
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)

                    Text("MedAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your health, connected.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Login Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)

                        TextField("Enter your email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)

                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField(
                                        "Enter your password",
                                        text: $password
                                    )
                                } else {
                                    SecureField(
                                        "Enter your password",
                                        text: $password
                                    )
                                }
                            }
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(
                                    systemName: isPasswordVisible
                                        ? "eye.slash"
                                        : "eye"
                                )
                                .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel(
                                isPasswordVisible
                                    ? "Hide password"
                                    : "Show password"
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await login()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .disabled(isLoading)
                }

                Spacer()

                Text("Securely manage your health information")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationBarHidden(true)
        }
    }

    @MainActor
    private func login() async {
        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        guard trimmedEmail.contains("@"),
              trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let response = try await AuthService.shared.login(
                email: trimmedEmail,
                password: password
            )

            print("Login succeeded.")
            print("Token type: \(response.token_type)")
            print("Token length: \(response.access_token.count)")

            AuthSession.shared.loginSucceeded(
                token: response.access_token
            )

            guard AuthSession.shared.isLoggedIn else {
                errorMessage = "Unable to save your login session. Please try again."
                return
            }

        } catch {
            print("Login error: \(error)")
            errorMessage = "Login failed. Please check your email and password."
        }
    }
}

#Preview {
    LoginView()
}
