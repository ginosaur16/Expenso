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
                        .font(.system(size: 200))
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
                    
                    Spacer()
                        .frame(height: 32)
                    
                    NavigationLink(destination: LoginView()
                        .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Continue")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .glassEffect(.clear.interactive())
                            .shadow(radius: 8)
                    }
                }
                .padding(40)
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntroView()
    }
}
