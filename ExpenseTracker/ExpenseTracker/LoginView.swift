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
    @FocusState private var isFocused: Bool
    
var body: some View {
    NavigationStack {
        ZStack {
            LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Text("💸")
                    .font(.system(size: 100))
                    .shadow(color: .black.opacity(0.75), radius: 5, x: 0, y: 3)
                
                Text("EXPENSO")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
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
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.25))
                            .offset(x: 1, y: 1)
                    )
                
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .preferredColorScheme(.light)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .preferredColorScheme(.light)
                    .padding(.horizontal)

                Button {
                    attemptLogin()
                } label: {
                    Text("Login")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .glassEffect(.clear.interactive())
                        .shadow(radius: 4)
                }
                .padding(.top, 8)

                NavigationLink("Donut have an account?") {
                    RegisterView()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .underline()
                .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: 400)
            .padding()
            
            VStack {
                Spacer()
                
                Text("2026. Developed by Giulliano Suarez.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 16)
            }
        }
        .onTapGesture {
            isFocused = false
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
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
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
