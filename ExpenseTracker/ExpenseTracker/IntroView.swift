//
//  IntroView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI

struct IntroView: View {

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Text("💸")
                        .font(.system(size: 150))
                        .shadow(color: .black.opacity(0.75), radius: 5, x: 0, y: 3)
                    
                    Text("Welcome to")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .overlay(
                            Text("Welcome to")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.25))
                                .offset(x: 1, y: 1)
                        )
                    
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
                    
                    Spacer()
                        .frame(height: 64)
                    
                    NavigationLink(destination: LoginView()
                        .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Continue")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                            .glassEffect(.clear.interactive())
                    }
                }
                .padding(40)

                VStack {
                    Spacer()
                    
                    Text("2026. Developed by Giulliano Suarez.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 16)
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
