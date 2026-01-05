//
//  RegisterView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    private enum Route: Hashable {
        case login
    }

    @Environment(\.modelContext) private var modelContext
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var navigateToLogin: Bool = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Title
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 8)

                    // Input fields container with glass effect
                    VStack(spacing: 12) {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Username", text: $username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                    )
                    .padding(.horizontal, 20)

                    // Register button with glass effect
                    Button(action: register) {
                        Text("Register")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                            )                }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)

                    Spacer()
                }
            }
            .alert("Incomplete Information! ⚠️", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .alert("Registration Successful 🎉", isPresented: $showSuccess) {
                Button("Continue") {
                    path.append(Route.login)
                }
            } message: {
                Text("Your account has been created successfully.")
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .login:
                    LoginView()
                }
            }
        }
    }
    private func register() {
        // Simple validation (optional)
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            validationMessage = "Please fill in all fields!"
            showValidationError = true
            return
        }

        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            username: username,
            email: email,
            password: password
        )

        modelContext.insert(newUser)
        do {
            try modelContext.save()
            // Optionally clear fields or navigate
            clearFields()
            showSuccess = true
            print("User registered successfully.")
        } catch {
            // Handle save error (show alert)
            print("Failed to save user: \(error)")
        }
    }

    private func clearFields() {
        firstName = ""
        lastName = ""
        username = ""
        email = ""
        password = ""
    }
}

#Preview {
    RegisterView()
}
