import SwiftUI

struct RegisterView: View {

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.08),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {

                    // Logo
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(.blue)
                        .padding(.top, 30)

                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))

                    Text("Create your MedAI account")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 15) {

                        TextField("Full Name", text: $fullName)
                            .textFieldStyle(.roundedBorder)

                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button {
                        print("Register tapped")
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    RegisterView()
}//
//  RegisterView.swift
//  MedAI
//
//  Created by Mac-11 on 08/10/26.
//

