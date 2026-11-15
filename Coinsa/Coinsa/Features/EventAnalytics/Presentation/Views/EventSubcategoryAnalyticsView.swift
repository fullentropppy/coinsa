//
//  EventSubcategoryAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import SwiftUI

/// Экран аналитики подкатегорий выбранной категории расходов.
struct EventSubcategoryAnalyticsView: View {
    // MARK: - Хранимые свойства
    
    private let category: ExpenseCategory
    private let amountMode: CategoryAmountMode
    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String
    
    // MARK: - Вычисляемые свойства
    
    private var subcategoryAmountDivisor: Double {
        switch amountMode {
        case .total: 1
        case .daily: max(Double(viewModel.totalDays), 1)
        }
    }
    
    // MARK: - Инициализация
    
    /// Создает экран аналитики подкатегорий.
    /// - Parameters:
    ///   - category: Категория расходов.
    ///   - amountMode: Режим отображения сумм.
    ///   - data: Аналитические данные события.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(
        category: ExpenseCategory,
        amountMode: CategoryAmountMode,
        data: EventCategoryAnalyticsData,
        screenContextSubtitle: String
    ) {
        self.category = category
        self.amountMode = amountMode
        self.viewModel = EventAnalyticsViewModel(data: data)
        self.screenContextSubtitle = screenContextSubtitle
    }
    
    // MARK: - Тело View
    
    var body: some View {
        subcategoryAnalyticsList
            .navigationTitle(category.localizedResource)
            .navigationSubtitle(screenContextSubtitle)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Основной контент
    
    private var subcategoryAnalyticsList: some View {
        let slices = viewModel.displayedSubcategorySlicesSortedByAmount(for: category)

        return List {
            Section {
                ForEach(slices) { slice in
                    NavigationLink {
                        AnalyticsDestinationView {
                            EventSubcategoryExpensesView(
                                subcategory: slice.subcategory,
                                data: viewModel.data,
                                screenContextSubtitle: screenContextSubtitle
                            )
                        }
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
                homeAmount: slice.homeAmount / subcategoryAmountDivisor,
                homeCurrency: viewModel.homeCurrency,
                expenseAmount: slice.locationAmount.map { $0 / subcategoryAmountDivisor },
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
        EventSubcategoryAnalyticsView(
            category: category,
            amountMode: .total,
            data: viewModel.eventAnalyticsData,
            screenContextSubtitle: trip.screenContextSubtitle
        )
    }
}
