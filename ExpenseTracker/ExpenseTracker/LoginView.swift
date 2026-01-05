//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
                .hidden()
                
                Text("💸")
                    .font(.system(size: 100))
                    .shadow(color: .black.opacity(0.75), radius: 5, x: 0, y: 3)
                
                Text("EXPENSO")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    .overlay(
                        Text("EXPENSO")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.25))
                            .offset(x: 1, y: 1)
                    )
                
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button {
                    attemptLogin()
                } label: {
                    Text("Login")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .glassEffect()
                }
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)
                )
                .padding(.top, 8)

                NavigationLink(destination: RegisterView()) {
                    Text("Donut have an account?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .underline()
                }
                .padding(.top, 8)
            }
            .padding(.top, 120)
            .padding(.bottom, 40)
            .frame(maxWidth: 400)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Login successfully" {
                    navigateToHome = true
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func attemptLogin() {
        // Basic validation
        guard !username.isEmpty, !password.isEmpty else {
            alertTitle = "Invalid or Incorrect Credentials."
            alertMessage = "Please enter both username and password."
            showAlert = true
            return
        }

        // Fetch user by username
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        descriptor.fetchLimit = 1

        do {
            let results = try modelContext.fetch(descriptor)
            if let user = results.first, user.password == password {
                alertTitle = "Login successfully"
                alertMessage = "Welcome back, \(user.firstName)!"
                showAlert = true
            } else {
                alertTitle = "Invalid or Incorrect Credentials."
                alertMessage = "The username or password you entered is incorrect."
                showAlert = true
            }
        } catch {
            alertTitle = "Invalid or Incorrect Credentials."
            alertMessage = "An error occurred while accessing your account. Please try again."
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
}
