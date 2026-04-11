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
    
    @State private var isShowingExpenseEdit = false

    private let expense: Expense
    
    // MARK: - Initialization

    init(expense: Expense) {
        self.expense = expense
    }
    
    // MARK: - Body

    var body: some View {
        expenseDetailForm
            .navigationTitle(expense.category.localized)
            .navigationSubtitle(expense.location.screenContextSubtitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingExpenseEdit) {
                ExpenseEditView(
                    expense: expense,
                    baseCurrency: settingsStore.baseCurrency
                ) {
                    dismiss()
                }
            }
            .onAppear {
                checkIfDeleted()
            }
    }

    // MARK: - Content
    
    private var expenseDetailForm: some View {
        Form {
            mainSection
            commentSection
        }
    }
    
    // MARK: - Sections

    private var mainSection: some View {
        Section {
            VStack(spacing: 14) {
                headerContent
                cardContent
            }
        }
    }
    
    @ViewBuilder
    private var commentSection: some View {
        if let comment = expense.comment {
            Section {
                Text(comment)
            }
        }
    }
    
    // MARK: - Components
    
    private var headerContent: some View {
        HStack {
            BadgeView(fillColor: Expense.badgeColor, icon: Expense.badgeIcon)
            BadgeView(fillColor: expense.category.badgeColor, icon: expense.category.badgeIcon)
            Spacer()
            DateLabel.secondarySmall(expense.date)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .center) {
            if settingsStore.baseCurrency == expense.localCurrency {
                amountText(expense.baseAmount, currency: settingsStore.baseCurrency)
                    .padding(28)
            } else {
                amountText(expense.localAmount, currency: expense.localCurrency)
                    .padding(28)
                Divider()
                amountAdditionalInfo
                    .padding(14)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func amountText(_ amount: Double, currency: Currency) -> some View {
        AmountText(amount, font: .title, currency: currency, currencyColor: .secondary)
    }
    
    private var amountAdditionalInfo: some View {
        let baseCurrencyCode = settingsStore.baseCurrency.code
        let parts = [
            "\(String(format: "%.2f", expense.baseAmount)) \(baseCurrencyCode)",
            "1 \(baseCurrencyCode) = \(String(format: "%g", expense.rateLocalToBase)) \(expense.localCurrency.code)"
        ]
        let info = parts.joined(separator: "  •  ")

        return Text(info)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.edit {
                isShowingExpenseEdit = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func checkIfDeleted() {
        if expense.modelContext == nil {
            dismiss()
        }
    }
}

// MARK: - Previews

private extension ExpenseDetailView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let expense = builder.fetchExpense(from: container)
        
        return NavigationStack {
            ExpenseDetailView(expense: expense)
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
