//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
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
                    // Login action here
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

                Button(action: {
                    // Sign up action here
                }) {
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
    }
}

#Preview {
    LoginView()
}
