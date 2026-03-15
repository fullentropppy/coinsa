//
//  ExpenseListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseListView: View {
    // MARK: - Stored Properties
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    
    @Query private var expenses: [Expense]
    
    @State private var deletionHandler = DeletionHandler<Expense>(
        messageKey: "expense.deletionConfirmation.message.single"
    )

    enum Presentation {
        case standalone
        case embedded
    }

    private let presentation: Presentation
    private let locationID: PersistentIdentifier
    private let onAddExpense: () -> Void

    // MARK: - Initialization

    init(
        locationID: PersistentIdentifier,
        onAddExpense: @escaping () -> Void,
        presentation: Presentation = .standalone
    ) {
        self.locationID = locationID
        self.onAddExpense = onAddExpense
        self.presentation = presentation

        _expenses = Query(
            filter: #Predicate<Expense> { $0.location.persistentModelID == locationID },
            sort: \.date
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            switch presentation {
            case .standalone:
                listContent
            case .embedded:
                embeddedContent
            }
        }
        .alert("expense.list.deletionConfirmation.title",
               isPresented: $deletionHandler.isShowingDeleteConfirmation
        ) {
            Button("expense.list.deletionConfirmation.delete", role: .destructive) {
                confirmDelete()
            }
            Button("common.cancel", role: .cancel) {
                cancelDelete()
            }
        } message: {
            Text(deletionHandler.confirmationMessage)
        }
        .overlay {
            if presentation == .standalone {
                emptyStateOverlay
            }
        }
    }

    // MARK: - Components

    private var listContent: some View {
        List {
            expenseSection
        }
    }

    @ViewBuilder
    private var embeddedContent: some View {
        expenseSection
    }

    @ViewBuilder
    private var expenseSection: some View {
        if expenses.isEmpty {
            emptyStateView
        } else {
            expenseRows
        }
    }

    private var expenseRows: some View {
        ForEach(expenses) { expense in
            ExpenseRowView(
                expense: expense,
                baseCurrencyOption: settingsStore.baseCurrencyOption
            )
        }
        .onDelete(perform: requestDelete)
    }

    @ViewBuilder
    private var emptyStateOverlay: some View {
        if expenses.isEmpty {
            emptyStateView
        }
    }

    private var emptyStateView: some View {
        EmptyStateView(
            imageName: "creditcard",
            title: "expense.list.empty.title",
            description: "expense.list.empty.description",
            buttonLabel: "expense.list.addExpense",
            onAddAction: { onAddExpense() }
        )
    }

    // MARK: - Actions
    
    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(items: offsets.map { expenses[$0] })
    }
    
    private func confirmDelete() {
        deletionHandler.confirmDelete { context.delete($0) }
    }
    
    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews
private extension ExpenseListView {
    static func preview(
        withExpenses: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withExpenses(withExpenses)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let locationID = builder.fetchLocation(from: container).persistentModelID
        
        return NavigationStack {
            ExpenseListView(locationID: locationID, onAddExpense: {})
                .modelContainer(container)
                .environment(settingsStore)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    ExpenseListView.preview(
        withExpenses: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    ExpenseListView.preview(
        withExpenses: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    ExpenseListView.preview(
        withExpenses: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    ExpenseListView.preview(
        withExpenses: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}
