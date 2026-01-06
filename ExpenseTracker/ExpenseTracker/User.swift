import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var password: String

    @Relationship(deleteRule: .cascade, inverse: \Expense.user)
    var expenses: [Expense] = []

    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         username: String,
         email: String,
         password: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.password = password
    }
}
