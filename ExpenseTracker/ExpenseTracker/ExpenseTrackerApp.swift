//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/2/26.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            IntroView()
        }
        .modelContainer(for: User.self)
    }
}
