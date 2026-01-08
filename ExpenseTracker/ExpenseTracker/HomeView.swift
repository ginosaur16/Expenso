//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Giulliano I. Suarez on 1/5/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showLogoutAlert = false
    @State private var showAddResultAlert = false
    @State private var addResultMessage = ""
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab: Tab = .expenso
    
    @State private var expensoDate: Date = .now
    @State private var expensoName: String = ""
    @State private var expensoCost: String = ""
    @State private var expensoType: String = "Food/Drink"
    @State private var paymentMethod: String = "Cash"
    @State private var remarks: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var isExportingCSV: Bool = false
    @State private var csvDocument: CSVDocument = CSVDocument(data: Data())
    @State private var showPostExportHistoryActionAlert: Bool = false
    @State private var showResetCarryoverAlert: Bool = false
    
    @AppStorage("currentUserID") private var currentUserID: String = ""
    @AppStorage("currentUsername") private var currentUsername: String = ""
    @AppStorage("carryoverDebt") private var carryoverDebtStorage: String = "0"
    
    // Expense must conform to Identifiable for sheet(item:) usage
    @State private var expenseBeingEdited: Expense? = nil

    @Query var users: [User]
    @Query var expenses: [Expense]

    init() {
        // Default unfiltered query; will be refined in body using .query modifier if needed
        _expenses = Query()
    }
    
    private var currentUser: User? {
        // Prefer resolving by username captured from LoginView
        if !currentUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let byUsername = users.first(where: { $0.username.caseInsensitiveCompare(currentUsername) == .orderedSame }) {
            return byUsername
        }
        // Fallback to stored user ID if available
        if let byID = users.first(where: { $0.id.uuidString == currentUserID }) {
            return byID
        }
        // Final fallback: first user in store
        return users.first
    }
    
    private var greetingTitle: String {
        let first = currentUser?.firstName ?? "there"
        return "Hi, \(first)!"
    }

    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "PHP"
        return f
    }
    
    private func formattedCost(_ decimal: Decimal) -> String {
        let nsNumber = decimal as NSDecimalNumber
        return currencyFormatter.string(from: nsNumber) ?? ""
    }
    
    private var carryoverDebt: Decimal {
        Decimal(string: carryoverDebtStorage) ?? 0
    }

    private func setCarryoverDebt(_ value: Decimal) {
        carryoverDebtStorage = NSDecimalNumber(decimal: value).stringValue
    }
    
    private var startOfCurrentMonth: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        return cal.date(from: comps) ?? Date()
    }

    private var endOfCurrentMonth: Date {
        let cal = Calendar.current
        if let start = cal.date(byAdding: DateComponents(month: 1, day: -1), to: startOfCurrentMonth) {
            return cal.date(bySettingHour: 23, minute: 59, second: 59, of: start) ?? Date()
        }
        return Date()
    }

    private var monthlyTotalForCurrentUser: Decimal {
        let cal = Calendar.current
        let filtered = expenses.filter { exp in
            guard exp.user == currentUser else { return false }
            return cal.isDate(exp.date, equalTo: startOfCurrentMonth, toGranularity: .month)
        }
        return filtered.reduce(Decimal(0)) { partial, exp in
            partial + exp.cost
        }
    }
    
    private var totalDebtForCurrentUser: Decimal {
        let userExpenses = expenses.filter { $0.user == currentUser }
        let creditCardTotal = userExpenses
            .filter { $0.paymentMethod == "Credit Card" }
            .reduce(Decimal(0)) { $0 + $1.cost }
        let debtPaymentsTotal = userExpenses
            .filter { $0.type == "Debt" && ($0.paymentMethod == "Cash" || $0.paymentMethod == "Debit/Cash Card" || $0.paymentMethod == "Debit Card") }
            .reduce(Decimal(0)) { $0 + $1.cost }
        return carryoverDebt + creditCardTotal - debtPaymentsTotal
    }
    
    private func generateCSV(for expenses: [Expense]) -> String {
        var rows: [String] = []
        // Header
        rows.append("Date,Name,Type,Payment Method,Cost,Remarks")
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for e in expenses {
            let dateStr = df.string(from: e.date)
            let name = e.name.replacingOccurrences(of: ",", with: " ")
            let type = e.type.replacingOccurrences(of: ",", with: " ")
            let pm = e.paymentMethod.replacingOccurrences(of: ",", with: " ")
            let costStr = NSDecimalNumber(decimal: e.cost).stringValue
            let remarksStr = (e.remarks ?? "").replacingOccurrences(of: ",", with: " ")
            rows.append("\(dateStr),\(name),\(type),\(pm),\(costStr),\(remarksStr)")
        }
        return rows.joined(separator: "\n")
    }

    private var isAddDisabledForDebtCC: Bool {
        return expensoType == "Debt" && paymentMethod == "Credit Card"
    }

    private func handleAddExpenso() {
        let trimmedName = expensoName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCost = expensoCost.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty,
              !trimmedCost.isEmpty,
              !expensoType.isEmpty,
              !paymentMethod.isEmpty,
              let user = currentUser,
              Decimal(string: trimmedCost) != nil else {
            addResultMessage = "Please fill out all fields"
            showAddResultAlert = true
            return
        }

        let newExpense = Expense(
            name: trimmedName,
            type: expensoType,
            cost: Decimal(string: trimmedCost) ?? Decimal(0),
            paymentMethod: paymentMethod,
            remarks: remarks,
            date: expensoDate,
            user: user
        )
        modelContext.insert(newExpense)

        do {
            try modelContext.save()
            addResultMessage = "Expenso added to your Expenso Log!"
            showAddResultAlert = true

            expensoDate = .now
            expensoName = ""
            expensoCost = ""
            expensoType = "Food/Drink"
            paymentMethod = "Cash"
            remarks = ""
            isFocused = false
        } catch {
            addResultMessage = "Something went wrong. Please try again."
            showAddResultAlert = true
        }
    }

    private struct ExpenseRowView: View {
        let expense: Expense
        let formattedCostText: String

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(expense.date, style: .date)
                        .font(.headline)
                    Spacer()
                    Text(formattedCostText)
                        .font(.headline)
                }
                Text(expense.name)
                    .font(.subheadline)
                HStack(spacing: 8) {
                    Label(expense.type, systemImage: "tag")
                    Label(expense.paymentMethod, systemImage: "creditcard")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                if let remarksText = expense.remarks, !remarksText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(remarksText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
    }

    private struct EditExpenseSheet: View {
        @Environment(\.dismiss) private var dismiss
        var expense: Expense
        var onSave: (Date, String, String, String, String, String) -> Void

        @State private var date: Date
        @State private var name: String
        @State private var cost: String
        @State private var type: String
        @State private var paymentMethod: String
        @State private var remarks: String

        init(expense: Expense, onSave: @escaping (Date, String, String, String, String, String) -> Void) {
            self.expense = expense
            self.onSave = onSave
            _date = State(initialValue: expense.date)
            _name = State(initialValue: expense.name)
            _cost = State(initialValue: NSDecimalNumber(decimal: expense.cost).stringValue)
            _type = State(initialValue: expense.type)
            _paymentMethod = State(initialValue: expense.paymentMethod)
            _remarks = State(initialValue: expense.remarks ?? "")
        }

        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("Expenso Date")) {
                        DatePicker("Date of Expenso", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    }
                    Section(header: Text("Details")) {
                        TextField("Expenso Name", text: $name)
                        TextField("Expenso Cost", text: $cost)
                            .keyboardType(.decimalPad)
                        Picker("Expenso Type", selection: $type) {
                            Text("Food/Drink").tag("Food/Drink")
                            Text("Transportation").tag("Transportation")
                            Text("Health/Meds").tag("Health/Meds")
                            Text("Vanity Items").tag("Vanity Items")
                            Text("Bills").tag("Bills")
                            Text("Debt").tag("Debt")
                            Text("Other").tag("Other")
                        }
                        Picker("Payment Method", selection: $paymentMethod) {
                            Text("Cash").tag("Cash")
                            Text("Credit Card").tag("Credit Card")
                            Text("Debit Card").tag("Debit Card")
                        }
                        TextField("Remarks (optional)", text: $remarks, axis: .vertical)
                    }
                }
                .navigationTitle("Edit Expenso")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave(date, name, cost, type, paymentMethod, remarks)
                            dismiss()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Decimal(string: cost) == nil)
                    }
                }
            }
        }
    }

    struct CSVDocument: FileDocument {
        static var readableContentTypes: [UTType] { [.commaSeparatedText] }
        static var writableContentTypes: [UTType] { [.commaSeparatedText] }

        var data: Data

        init(data: Data) {
            self.data = data
        }

        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents else {
                throw CocoaError(.fileReadCorruptFile)
            }
            self.data = data
        }

        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            return .init(regularFileWithContents: data)
        }
    }

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
                        Text("Expenso 💸")
                            .font(.largeTitle)
                            .frame(width: 320)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.top, 5)
                            .padding(.bottom, 16)
                        
                        VStack(spacing: 16) {
                            Text("Expenso Date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            DatePicker("Date of Expenso", selection: $expensoDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .glassEffect(.clear)
                                .labelsHidden()
                                .frame(height: 90)
                                .clipped()
                            
                            Divider()
                                .padding(8)

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    TextField("Name of Expenso", text: $expensoName)
                                        .ignoresSafeArea(.keyboard, edges: .bottom)
                                        .textFieldStyle(.roundedBorder)
                                        .cornerRadius(16)
                                        .focused($isFocused)
                                        .preferredColorScheme(.light)
                                        .frame(width: 180)
                                    Text("PHP")
                                    TextField("Cost", text: $expensoCost)
                                        .ignoresSafeArea(.keyboard, edges: .bottom)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.roundedBorder)
                                        .cornerRadius(16)
                                        .focused($isFocused)
                                        .preferredColorScheme(.light)
                                        .frame(width: 85)
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                                HStack(spacing: 16) {
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Expenso Type")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal)
                                        Picker("Expenso Type", selection: $expensoType) {
                                            Text("Food/Drink").tag("Food/Drink")
                                            Text("Transpo").tag("Transportation")
                                            Text("Health/Meds").tag("Health/Meds")
                                            Text("Vanity Items").tag("Vanity Items")
                                            Text("Bills").tag("Bills")
                                            Text("Debt").tag("Debt")
                                            Text("Other").tag("Other")
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 150)
                                        .padding(2)
                                        .glassEffect(.clear.interactive())
                                    }

                                    VStack(alignment: .center, spacing: 4) {
                                        Text("Payment Method")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal)
                                        Picker("Payment Method", selection: $paymentMethod) {
                                            Text("Cash").tag("Cash")
                                            Text("Credit Card").tag("Credit Card")
                                            Text("Debit Card").tag("Debit Card")
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 150)
                                        .padding(2)
                                        .glassEffect(.clear.interactive())
                                    }
                                }

                                TextField("Remarks", text: $remarks, axis: .vertical)
                                    .glassEffect(in: .rect(cornerRadius: 4))
                                    .ignoresSafeArea(.keyboard, edges: .bottom)
                                    .focused($isFocused)
                                    .lineLimit(4...6)
                                    .frame(width: 325)
                                    .padding()
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                                    .frame(height: 20)
                                Button("Add Expenso") {
                                    handleAddExpenso()
                                }
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 36)
                                .padding(.vertical, 14)
                                .glassEffect(.clear.interactive())
                                .opacity(isAddDisabledForDebtCC ? 0.5 : 1.0)
                                .disabled(isAddDisabledForDebtCC)
                                
                                if paymentMethod == "Credit Card" && expensoType == "Debt" {
                                    Text("Cannot add Credit Card Payment to Debt. Please select another payment method or type.")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                        .frame(maxWidth: .infinity)
                                } else if expensoType == "Debt" {
                                    Text("You have selected Debt, please select either Cash or Debit Card payment method.")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                        .frame(maxWidth: .infinity)
                                } else if paymentMethod == "Credit Card" {
                                    Text("You have selected Credit Card Payment, this will be added in your total debt.")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                        .frame(maxWidth: .infinity)
                                }
                                
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

                    VStack(alignment: .center, spacing: 8) {
                        Text("History 🧾")
                            .font(.largeTitle)
                            .frame(width: 320)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                        
                        if expenses.filter({ $0.user == currentUser }).isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text("No Expenso Yet")
                                    .font(.headline)
                                Text("Add an Expenso to see it here.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Total Expenso:")
                                        .font(.headline)
                                    Spacer()
                                    Text(formattedCost(monthlyTotalForCurrentUser))
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Total Debt:")
                                        .font(.headline)
                                    Spacer()
                                    Text(formattedCost(totalDebtForCurrentUser))
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                
                                Text("Swipe Left for more options.")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                List {
                                    ForEach(expenses.filter { $0.user == currentUser }) { expense in
                                        ExpenseRowView(
                                            expense: expense,
                                            formattedCostText: formattedCost(expense.cost)
                                        )
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                modelContext.delete(expense)
                                                try? modelContext.save()
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                expenseBeingEdited = expense
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.blue)
                                        }
                                    }
                                }
                                .listStyle(.insetGrouped)
                                .scrollContentBackground(.hidden)
                            }
                        }
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

                    VStack(spacing: 16) {
                        Text("Profile 🐥")
                            .font(.largeTitle)
                            .frame(width: 320)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Spacer()
                        Text("Welcome \(currentUser?.firstName ?? "") \(currentUser?.lastName ?? "")! This is your Profile Tab. Thank you for using Expenso as your daily expenses tracker!")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .padding()
                        
                        VStack(spacing: 12) {
                            Text("Debt Transparency")
                                .font(.headline)

                            // Carryover display
                            HStack {
                                Text("Carryover Debt:")
                                Spacer()
                                Text(formattedCost(carryoverDebt))
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal)

                            // Current period components display
                            let userExpenses = expenses.filter { $0.user == currentUser }
                            let creditCardTotal = userExpenses
                                .filter { $0.paymentMethod == "Credit Card" }
                                .reduce(Decimal(0)) { $0 + $1.cost }
                            let debtPaymentsTotal = userExpenses
                                .filter { $0.type == "Debt" && ($0.paymentMethod == "Cash" || $0.paymentMethod == "Debit/Cash Card" || $0.paymentMethod == "Debit Card") }
                                .reduce(Decimal(0)) { $0 + $1.cost }

                            HStack {
                                Text("New CC Charges:")
                                Spacer()
                                Text(formattedCost(creditCardTotal))
                            }
                            .padding(.horizontal)

                            HStack {
                                Text("Debt Payments:")
                                Spacer()
                                Text("-\(formattedCost(debtPaymentsTotal))")
                            }
                            .padding(.horizontal)

                            Divider()
                            HStack {
                                Text("Total Debt:")
                                Spacer()
                                Text(formattedCost(carryoverDebt + creditCardTotal - debtPaymentsTotal))
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)

                            Button(role: .destructive) {
                                showResetCarryoverAlert = true
                            } label: {
                                Label("Reset Debt (Clear Carryover)", systemImage: "arrow.counterclockwise")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(greetingTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selectedTab == .history {
                        Button {
                            // Build CSV for current user's expenses or alert if none
                            let userExpenses = expenses.filter { $0.user == currentUser }
                            if userExpenses.isEmpty {
                                addResultMessage = "No Expenso yet to export."
                                showAddResultAlert = true
                            } else {
                                let csv = generateCSV(for: userExpenses)
                                csvDocument = CSVDocument(data: csv.data(using: .utf8) ?? Data())
                                isExportingCSV = true
                            }
                        } label: {
                            Label("Export", systemImage: "doc.text")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogoutAlert = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .fileExporter(
                isPresented: $isExportingCSV,
                document: csvDocument,
                contentType: .commaSeparatedText,
                defaultFilename: "Expenses-\(expensoDate).csv"
            ) { result in
                switch result {
                case .success:
                    addResultMessage = "CSV exported successfully."
                    showPostExportHistoryActionAlert = true
                case .failure:
                    addResultMessage = "Failed to export CSV."
                }
                showAddResultAlert = true
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                isFocused = false
            }
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    // Clear current user session
                    currentUserID = ""
                    currentUsername = ""
                    selectedTab = .expenso
                    navigationPath = NavigationPath()
                    navigationPath.append("login")
                }
            } message: {
                Text("Do you really want to log out?")
            }
            .alert(addResultMessage, isPresented: $showAddResultAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Manage History", isPresented: $showPostExportHistoryActionAlert) {
                Button("Keep", role: .cancel) {
                    // Do nothing, keep history
                }
                Button("Delete All", role: .destructive) {
                    setCarryoverDebt(totalDebtForCurrentUser)
                    // Delete all expenses for current user
                    let userExpenses = expenses.filter { $0.user == currentUser }
                    for exp in userExpenses {
                        modelContext.delete(exp)
                    }
                    try? modelContext.save()
                }
            } message: {
                Text("CSV exported successfully. Do you want to keep your current history of expenses or delete all of it?")
            }
            .alert("Reset Carryover Debt", isPresented: $showResetCarryoverAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    setCarryoverDebt(0)
                }
            } message: {
                Text("This will set your Carryover Debt to 0. This does not delete any history.")
            }
            .sheet(item: $expenseBeingEdited) { expense in
                EditExpenseSheet(
                    expense: expense,
                    onSave: { updatedDate, updatedName, updatedCostString, updatedType, updatedPaymentMethod, updatedRemarks in
                        expense.date = updatedDate
                        expense.name = updatedName
                        if let dec = Decimal(string: updatedCostString) { expense.cost = dec }
                        expense.type = updatedType
                        expense.paymentMethod = updatedPaymentMethod
                        expense.remarks = updatedRemarks
                        try? modelContext.save()
                    }
                )
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
