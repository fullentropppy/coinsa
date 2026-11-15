//
//  EventSubcategoryAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import SwiftUI

/// Экран аналитики подкатегорий выбранной категории расходов.
struct EventSubcategoryAnalyticsView: View, Equatable {
    // MARK: - Хранимые свойства
    
    private let viewModel: EventSubcategoryAnalyticsViewModel
    private let screenContextSubtitle: String
    
    // MARK: - Инициализация
    
    /// Создает экран из данных только выбранной категории.
    /// - Parameters:
    ///   - viewModel: Отобранные траты категории и параметры отображения сумм.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(
        viewModel: EventSubcategoryAnalyticsViewModel,
        screenContextSubtitle: String
    ) {
        self.viewModel = viewModel
        self.screenContextSubtitle = screenContextSubtitle
    }
    
    // MARK: - Тело View
    
    var body: some View {
        subcategoryAnalyticsList
            .navigationTitle(viewModel.category.localizedResource)
            .navigationSubtitle(screenContextSubtitle)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Основной контент
    
    private var subcategoryAnalyticsList: some View {
        let slices = viewModel.displayedSlices
        let expensesBySubcategory = viewModel.expensesBySubcategory
        let showsLocationNames = viewModel.showsLocationNames
        let screenContextSubtitle = screenContextSubtitle

        return List {
            Section {
                ForEach(slices) { slice in
                    let expenses = expensesBySubcategory[slice.subcategory] ?? []

                    NavigationLink { [subcategory = slice.subcategory, expenses, showsLocationNames, screenContextSubtitle] in
                        EventSubcategoryExpensesView(
                            subcategory: subcategory,
                            expenses: expenses,
                            showsLocationNames: showsLocationNames,
                            screenContextSubtitle: screenContextSubtitle
                        )
                    } label: {
                        legendRow(for: slice, slices: slices)
                    }
                }
            }
        }
    }

    
    // MARK: - Компоненты
    
    private func legendRow(for slice: ExpenseSubcategoryAnalyticsSlice, slices: [ExpenseSubcategoryAnalyticsSlice]) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
                Text(slice.subcategory.localizedResource)
                HStack(spacing: ViewLayout.Row.metadataSpacing) {
                    Image(systemName: slice.subcategory.secondaryIcon)
                        .imageScale(.small)
                        .foregroundStyle(slice.subcategory.accentColor.gradient)
                        .frame(width: ViewLayout.Row.iconWidth)
                    Text(viewModel.shareValue(for: slice, among: slices).percentFormat())
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                       
                    DotDivider.secondarySmall()
                    
                    CountLabel.secondarySmall(
                        slice.expenseCount,
                        icon: Expense.primaryIcon
                    )
                }
            }
            Spacer()
            AmountStack(
                homeAmount: slice.homeAmount / viewModel.amountDivisor,
                homeCurrency: viewModel.homeCurrency,
                expenseAmount: slice.locationAmount.map { $0 / viewModel.amountDivisor },
                expenseCurrency: viewModel.locationCurrency
            )
        }
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let viewModel = TripDetailViewModel(trip: trip)
    let analyticsViewModel = EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
    let category = analyticsViewModel.displayedSlicesSortedByAmount(
        for: .categories
    ).first?.category ?? .defaultValue

    NavigationStack {
        if let categoryViewModel = analyticsViewModel.subcategoryViewModels(amountMode: .total)[category] {
            EventSubcategoryAnalyticsView(
                viewModel: categoryViewModel,
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
    }
}
