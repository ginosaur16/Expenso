import Foundation
import SwiftData

@Model
final class Expense {
    var name: String            // Name of Expense
    var type: String            // Type of Expense
    var cost: Decimal           // Cost
    var paymentMethod: String   // Payment Method
    var remarks: String?        // Remarks
    var date: Date              // Optional, default to now
    var user: User?             // inverse relationship target

    init(id: UUID = UUID(),
         name: String,
         type: String,
         cost: Decimal,
         paymentMethod: String,
         remarks: String? = nil,
         date: Date = .now,
         user: User? = nil) {
        self.name = name
        self.type = type
        self.cost = cost
        self.paymentMethod = paymentMethod
        self.remarks = remarks
        self.date = date
        self.user = user
    }
}
