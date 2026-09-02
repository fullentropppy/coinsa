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
                    angle: .value("", slice.baseAmount),
                    innerRadius: 68,
                    angularInset: 1,
                )
                .cornerRadius(6)
                .foregroundStyle(slice.category.accentColor.gradient)
            }
            .frame(height: 220)
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
                if slice.baseAmount > 0 {
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

private extension EventAnalyticsCategoriesBody {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsCategoriesBody(
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
    EventAnalyticsCategoriesBody.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsCategoriesBody.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
