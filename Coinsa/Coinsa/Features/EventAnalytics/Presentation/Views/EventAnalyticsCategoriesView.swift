//
//  EventAnalyticsCategoriesView.swift
//  Coinsa
//
//  Created by OpenAI on 23.08.2026.
//

import Charts
import SwiftUI

/// Вкладка аналитики расходов по категориям.
struct EventAnalyticsCategoriesView: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var categoryAmountMode: CategoryAmountMode = .total

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

    /// Создает вкладку аналитики категорий.
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
            categoriesHeaderSection
            categoriesChartSection
            categoriesLegendSection
        }
    }

    // MARK: - Секции

    private var categoriesHeaderSection: some View {
        Section {
            HStack {
                EventAmountCardView(
                    title: .amountExpenses,
                    baseAmount: viewModel.expensesTotalBaseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.expensesTotalLocationAmount,
                    locationCurrency: viewModel.locationCurrency
                )
                if viewModel.totalDays > 1 {
                    EventAmountCardView(
                        title: .amountExpensesDaily,
                        baseAmount: viewModel.dailyBaseExpensesAmount,
                        baseCurrency: viewModel.baseCurrency,
                        locationAmount: viewModel.dailyLocationExpensesAmount,
                        locationCurrency: viewModel.locationCurrency
                    )
                }
            }
        }
    }

    private var categoriesChartSection: some View {
        Section {
            Chart(displayedSlicesSortedByID, id: \.category.id) { slice in
                SectorMark(
                    angle: .value("", slice.baseAmount),
                    innerRadius: 68,
                    angularInset: 1,
                )
                .cornerRadius(6)
                .foregroundStyle(slice.category.accentColor.gradient)
            }
            .frame(height: 220)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: categoryAmountMode)
        }
        .listRowBackground(Color.clear)
    }

    private var categoriesLegendSection: some View {
        Section {
            if viewModel.totalDays > 1 {
                Picker("", selection: $categoryAmountMode) {
                    ForEach(CategoryAmountMode.allCases) { mode in
                        Text(mode.localizedResource).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: categoryAmountMode) {
                    haptics.trigger(.tap)
                }
                .listRowSeparator(.hidden)
            }

            ForEach(displayedSlicesSortedByAmount) { slice in
                NavigationLink {
                    EventSubcategoryAnalyticsView(
                        category: slice.category,
                        amountMode: categoryAmountMode,
                        data: viewModel.data,
                        screenContextSubtitle: screenContextSubtitle
                    )
                } label: {
                    categoriesChartLegendRow(for: slice)
                }
            }
        }
    }

    // MARK: - Компоненты

    private func categoriesChartLegendRow(for slice: ExpenseAnalyticsSlice) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(slice.category.localizedResource)
                HStack {
                    slice.category.makeDot()
                    Text(shareValue(for: slice).percentFormat())
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            AmountStack(
                baseAmount: slice.baseAmount / categoryAmountDivisor,
                baseCurrency: viewModel.baseCurrency,
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

private extension EventAnalyticsCategoriesView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsCategoriesView(
                    viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData),
                    screenContextSubtitle: trip.screenContextSubtitle
                )
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsCategoriesView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsCategoriesView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
