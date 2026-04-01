//
//  ExpenseDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    // MARK: - Stored Properties

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    
    @Query private var expenses: [Expense]

    @State private var isShowingExpenseEdit = false

    let expenseID: PersistentIdentifier

    // MARK: - Initialization

    init(expenseID: PersistentIdentifier) {
        self.expenseID = expenseID
        _expenses = Query(
            filter: #Predicate<Expense> { $0.persistentModelID == expenseID }
        )
    }
    
    // MARK: - Body

    var body: some View {
        Group {
            if let expense = expenses.first {
                expenseDetailContent(expense: expense)
            } else {
                ProgressView()
            }
        }
    }

    // MARK: - Content
    
    private func expenseDetailContent(expense: Expense) -> some View {
        expenseDetailForm(expense: expense)
            .navigationTitle(expense.category.localized)
            .navigationSubtitle(expense.location.screenContextSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingExpenseEdit) {
                ExpenseEditView(
                    expense: expense,
                    baseCurrency: settingsStore.baseCurrency
                ) {
                    isShowingExpenseEdit = false
                    dismiss()
                }
            }
    }
    
    private func expenseDetailForm(expense: Expense) -> some View {
        Form {
            mainSection(expense: expense)
            if let comment = expense.comment {
                commentSection(comment: comment)
            }
        }
    }
    
    // MARK: - Sections

    private func mainSection(expense: Expense) -> some View {
        Section {
            VStack(spacing: 14) {
                headerContent(expense: expense)
                cardContent(expense: expense)
            }
        }
    }
    
    private func commentSection(comment: String) -> some View {
        Section {
            Text(comment)
        }
    }
    
    // MARK: - Components
    
    private func headerContent(expense: Expense) -> some View {
        HStack {
            BadgeView(
                fillColor: Expense.badgeColor,
                icon: Expense.badgeIcon
            )
            BadgeView(
                fillColor: expense.category.badgeColor,
                icon: expense.category.badgeIcon
            )
            
            Spacer()
    
            DateLabel.secondarySmall(expense.date)
        }
    }
    
    private func cardContent(expense: Expense) -> some View {
        let localCurrency = Currency.from(expense.location.currencyCodeLocal)

        return VStack(alignment: .center) {
            AmountText(
                expense.amountLocal,
                font: .title,
                currency: localCurrency
            )
            .padding(28)
            
            Divider()
            
            amountAdditionalInfo(expense: expense, localCurrency: localCurrency)
                .padding(14)
        }
        .padding(10)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }
    
    private func amountAdditionalInfo(expense: Expense, localCurrency: Currency) -> some View {
        let baseCurrencyCode = settingsStore.baseCurrency.code
        
        let info = "\(expense.amountBase) \(baseCurrencyCode)"
        + "  •  "
        + "1 \(baseCurrencyCode) = \(String(format: "%g", expense.rateLocalToBase)) \(localCurrency.code)"

        return Text(info)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButtonView.edit {
                isShowingExpenseEdit = true
            }
        }
    }
}

// MARK: - Previews

private extension ExpenseDetailView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let expenseID = builder.fetchExpense(from: container).persistentModelID
        
        return NavigationStack {
            ExpenseDetailView(expenseID: expenseID)
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
