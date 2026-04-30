//
//  ExpenseDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    // MARK: - Хранимые свойства

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingExpenseEdit = false

    private let expense: Expense
    
    // MARK: - Вычисляемые свойства

    private var viewModel: ExpenseDetailViewModel {
        ExpenseDetailViewModel(expense: expense)
    }

    // MARK: - Инициализация

    init(_ expense: Expense) {
        self.expense = expense
    }
    
    // MARK: - Тело View

    var body: some View {
        expenseDetailForm
            .navigationTitle(viewModel.navigationTitle)
            .navigationSubtitle(viewModel.navigationSubtitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingExpenseEdit) {
                ExpenseEditView(forEdit: expense) {
                    dismiss()
                }
            }
            .onAppear {
                checkIfDeleted()
            }
    }

    // MARK: - Основной контент
    
    private var expenseDetailForm: some View {
        Form {
            mainSection
            commentSection
        }
    }
    
    // MARK: - Секции

    private var mainSection: some View {
        Section {
            VStack(spacing: 14) {
                headerContent
                cardContent
                additionalInfoContent
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
    
    // MARK: - Компоненты
    
    private var headerContent: some View {
        HStack {
            Expense.makeBadge()
            expense.category.makeBadge()
            Spacer()
            DateLabel.secondarySmall(expense.date)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .center) {
            AmountText(
                viewModel.primaryAmount,
                font: .title,
                currency: viewModel.primaryCurrency,
                currencyFont: .title.monospaced(),
                currencyColor: .secondary
            )
            .padding(.top, 28)
            .padding(.bottom, 14)
            
            HStack(spacing: 6) {
                Image(systemName: expense.paymentMethod.primaryIcon)
                    .imageScale(.medium)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 28)
            
            if let secondaryAmount = viewModel.secondaryAmount,
               let secondaryCurrency = viewModel.secondaryCurrency {
                Divider()
                
                AmountText(
                    secondaryAmount,
                    font: .body.monospacedDigit(),
                    color: .secondary,
                    currency: secondaryCurrency,
                    currencyFont: .body.monospaced()
                )
                .padding(14)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    private var additionalInfoContent: some View {
        if let exchangeRateDescription = viewModel.exchangeRateDescription {
            Text(exchangeRateDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.edit {
                isShowingExpenseEdit = true
            }
        }
    }
    
    // MARK: - Действия
    
    private func checkIfDeleted() {
        if expense.modelContext == nil {
            dismiss()
        }
    }
}

// MARK: - Превью

private extension ExpenseDetailView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let expense = builder.fetchExpense(from: container)
        
        return NavigationStack {
            ExpenseDetailView(expense)
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
