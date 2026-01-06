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
    @State private var selectedTab: Tab = .expenso
    
    @State private var expensoDate: Date = .now
    @State private var expensoName: String = ""
    @State private var expensoCost: String = ""
    @State private var expensoType: String = "Food/Drink"
    @State private var paymentMethod: String = "Cash"
    @State private var remarks: String = ""

    @Query var users: [User]

    enum Tab {
        case expenso
        case history
        case profile
    }
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {

                // Expenso Tab
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
                            .padding(.top, 5)
                        
                        VStack(spacing: 12) {
                            DatePicker("Date of Expenso", selection: $expensoDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .glassEffect(.clear.interactive())

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    TextField("Name of Expenso", text: $expensoName)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 180)
                                    Text("PHP")
                                    TextField("Cost", text: $expensoCost)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                                HStack(spacing: 16) { // Type of Expenso Picker
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Expenso Type")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal)
                                        Picker("Expenso Type", selection: $expensoType) {
                                            Text("Food/Drink").tag("Food/Drink")
                                            Text("Transportation").tag("Transportation")
                                            Text("Health/Meds").tag("Health/Meds")
                                            Text("Vanity Items").tag("Vanity Items")
                                            Text("Bills").tag("Bills")
                                            Text("Other").tag("Other")
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 150)
                                        .padding(2)
                                        .glassEffect(.clear.interactive())
                                    }

                                    // Payment Method Picker
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Payment Method")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal)
                                        Picker("Payment Method", selection: $paymentMethod) {
                                            Text("Cash").tag("Cash")
                                            Text("Credit Card").tag("Credit Card")
                                            Text("Debit/Cash Card").tag("Debit/Cash Card")
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 150)
                                        .padding(2)
                                        .glassEffect(.clear.interactive())
                                    }
                                }

                                TextField("Remarks", text: $remarks, axis: .vertical)
                                    .glassEffect(in: .rect(cornerRadius: 4))
                                    .lineLimit(4...6)
                                    .frame(width: 325)
                                    .padding()

                                // Add Expenso Button
                                Button("Add Expenso") {
                                    // Action to add expenso will be implemented later
                                }
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 36)
                                .padding(.vertical, 14)
                                .glassEffect(.clear.interactive())
                                .shadow(radius: 8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(width: 360)

                        Spacer()
                    }
                }
                .tabItem {
                    Label("Expenso", systemImage: "banknote.fill")
                }
                .tag(Tab.expenso)

                // History Tab
                ZStack {
                    LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()

                    VStack {
                        Text("History")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

                // Profile Tab
                ZStack {
                    LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()

                    VStack {
                        Text("Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Hi, \(users.first?.firstName ?? "there")!")
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
