//
//  IntroView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI

struct IntroView: View {
    private enum NavigationTarget: Hashable {
        case login
    }
    
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Text("💸")
                        .font(.system(size: 200))
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
                    
                    Spacer()
                        .frame(height: 32)
                    
                    NavigationLink(value: NavigationTarget.login) {
                        Text("Continue")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .glassEffect()
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .background(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                            )
                    }
                }
                .padding(40)
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .login:
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntroView()
    }
}
