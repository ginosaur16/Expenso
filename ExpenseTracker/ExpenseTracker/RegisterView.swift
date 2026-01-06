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
    @Query(sort: \User.username) private var users: [User]
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var showLoginAfterRegister = false
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                            .focused($isFocused)
                            .preferredColorScheme(.light)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                            .focused($isFocused)
                            .preferredColorScheme(.light)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Username", text: $username)
                            .textContentType(.username)
                            .focused($isFocused)
                            .preferredColorScheme(.light)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .focused($isFocused)
                            .preferredColorScheme(.light)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .focused($isFocused)
                            .preferredColorScheme(.light)
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

                    Button(action: register) {
                        Text("Register")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .glassEffect(.clear.interactive())
                            .shadow(radius: 4)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 15)

                    List {
                        Section("Registered Users") {
                            ForEach(users) { user in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.headline)
                                    Text("@\(user.username)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(user.email)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteUser(user)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .onTapGesture {
                isFocused = false
            }
            .alert("Incomplete Information! ⚠️", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .alert("Registration Successful 🎉", isPresented: $showSuccess) {
                Button("Continue") {
                    showLoginAfterRegister = true
                }
            } message: {
                Text("Your account has been created successfully.")
            }
            .fullScreenCover(isPresented: $showLoginAfterRegister) {
                LoginView()
            }
        }
    }
    private func register() {
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

    private func deleteUser(_ user: User) {
        modelContext.delete(user)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete user: \(error)")
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
