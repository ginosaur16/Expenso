//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/5/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showLogoutAlert = false
    @State private var navigationPath = NavigationPath()
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Text("What Expenso have you made? 💸🥹")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 40)
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .glassEffect(.clear.interactive())
                        .shadow(radius: 4)
                    }
                }
                .alert("Log Out", isPresented: $showLogoutAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Log Out", role: .destructive) {
                        navigationPath.append("login")
                    }
                } message: {
                    Text("Do you really want to log out?")
                }
            }
        }
        .navigationDestination(for: String.self) { route in
            if route == "login" {
                LoginView()
            }
        }
    }
}

#Preview {
    HomeView()
}
