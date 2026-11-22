//
//  EventAnalyticsCategoriesBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import Charts
import SwiftUI

/// Тело вкладки аналитики расходов по категориям.
struct EventAnalyticsCategoriesBody: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var categoryAmountMode: CategoryAmountMode = .total
    @State private var isChartVisible = false

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String

    // MARK: - Вычисляемые свойства

    private var displayedSlicesSortedByID: [ExpenseAnalyticsSlice] {
        viewModel.displayedSlicesSortedByID(for: .categories)
    }

    private var displayedSlicesSortedByAmount: [ExpenseAnalyticsSlice] {
        viewModel.displayedSlicesSortedByAmount(for: .categories)
    }

    private var categoryAmountDivisor: Double {
        switch categoryAmountMode {
        case .total: 1
        case .daily: max(Double(viewModel.totalDays), 1)
        }
    }

    // MARK: - Инициализация

    /// Создает тело вкладки аналитики категорий.
    /// - Parameters:
    ///   - viewModel: ViewModel аналитики события.
    ///   - screenContextSubtitle: Подзаголовок экрана для вложенной аналитики.
    init(viewModel: EventAnalyticsViewModel, screenContextSubtitle: String) {
        self.viewModel = viewModel
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        categoriesContent
    }

    // MARK: - Основной контент

    private var categoriesContent: some View {
        Group {
            categoriesChartSection
            categoriesLegendSection
        }
    }

    // MARK: - Секции

    private var categoriesChartSection: some View {
        Section {
            Chart(displayedSlicesSortedByID, id: \.category.id) { slice in
                SectorMark(
                    angle: .value("", slice.homeAmount),
                    innerRadius: .fixed(ViewLayout.AnalyticsDonutChart.innerRadius),
                    angularInset: ViewLayout.AnalyticsDonutChart.angularInset
                )
                .cornerRadius(ViewLayout.AnalyticsDonutChart.sectorCornerRadius)
                .foregroundStyle(slice.category.accentColor.gradient)
            }
            .frame(height: ViewLayout.AnalyticsDonutChart.height)
            .opacity(isChartVisible ? 1 : 0)
            .animation(.snappy, value: isChartVisible)
            .onAppear {
                isChartVisible = true
            }
        }
        .listRowBackground(Color.clear)
    }

    private var categoriesLegendSection: some View {
        let categoryViewModels = viewModel.subcategoryViewModels(amountMode: categoryAmountMode)
        let screenContextSubtitle = screenContextSubtitle

        return Section {
            if viewModel.totalDays > 1 {
                Picker(selection: $categoryAmountMode) {
                    ForEach(CategoryAmountMode.allCases) { mode in
                        Text(mode.localizedResource).tag(mode)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .onChange(of: categoryAmountMode) {
                    haptics.trigger(.tap)
                }
                .listRowSeparator(.hidden)
            }

            ForEach(displayedSlicesSortedByAmount) { slice in
                if slice.homeAmount > 0, let categoryViewModel = categoryViewModels[slice.category] {
                    NavigationLink { [categoryViewModel, screenContextSubtitle] in
                        EventSubcategoryAnalyticsView(
                            viewModel: categoryViewModel,
                            screenContextSubtitle: screenContextSubtitle
                        )
                        .equatable()
                    } label: {
                        categoriesChartLegendRow(for: slice, expenseCount: categoryViewModel.expenses.count)
                    }
                }
            }
        }
    }

    // MARK: - Компоненты

    private func categoriesChartLegendRow(for slice: ExpenseAnalyticsSlice, expenseCount: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
                Text(slice.category.localizedResource)
                HStack(spacing: ViewLayout.Row.metadataSpacing) {
                    slice.category.makeDot()
                    Text(shareValue(for: slice).percentFormat())
                        .appTextStyle(.secondaryNumber)
                    
                    DotDivider.secondarySmall()
                    
                    CountLabel.secondarySmall(
                        expenseCount,
                        icon: Expense.primaryIcon
                    )
                }
            }
            Spacer()
            AmountStack(
                homeAmount: slice.homeAmount / categoryAmountDivisor,
                homeCurrency: viewModel.homeCurrency,
                expenseAmount: slice.locationAmount.map { $0 / categoryAmountDivisor },
                expenseCurrency: viewModel.locationCurrency
            )
        }
    }

    // MARK: - Вспомогательные методы

    private func shareValue(for slice: ExpenseAnalyticsSlice) -> Double {
        viewModel.shareValue(for: slice, metric: .categories)
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let viewModel = TripDetailViewModel(trip: trip)

    NavigationStack {
        List {
            EventAnalyticsCategoriesBody(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData),
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
    }
}
