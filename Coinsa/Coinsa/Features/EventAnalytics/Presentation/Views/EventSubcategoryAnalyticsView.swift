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
    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String
    
    // MARK: - Вычисляемые свойства
    
    private var displayedSlicesSortedByAmount: [ExpenseSubcategoryAnalyticsSlice] {
        viewModel.displayedSubcategorySlicesSortedByAmount(for: category)
    }
    
    // MARK: - Инициализация
    
    /// Создает экран аналитики подкатегорий.
    /// - Parameters:
    ///   - category: Категория расходов.
    ///   - data: Аналитические данные события.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(category: ExpenseCategory, data: EventCategoryAnalyticsData, screenContextSubtitle: String) {
        self.category = category
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
        List {
            Section {
                ForEach(displayedSlicesSortedByAmount) { slice in
                    legendRow(for: slice)
                }
            }
        }
    }
    
    // MARK: - Компоненты
    
    private func legendRow(for slice: ExpenseSubcategoryAnalyticsSlice) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(slice.subcategory.localizedResource)
                HStack {
                    Image(systemName: slice.subcategory.secondaryIcon)
                        .imageScale(.small)
                        .foregroundStyle(slice.subcategory.accentColor)
                        .frame(width: 20)
                    Text(shareValue(for: slice).percentFormat())
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            AmountStack(
                baseAmount: slice.baseAmount,
                baseCurrency: viewModel.baseCurrency,
                expenseAmount: slice.locationAmount,
                expenseCurrency: viewModel.locationCurrency
            )
        }
    }

    // MARK: - Вспомогательные методы
    
    private func shareValue(for slice: ExpenseSubcategoryAnalyticsSlice) -> Double {
        viewModel.shareValue(for: slice, category: category)
    }
}
// MARK: - Превью

private extension EventSubcategoryAnalyticsView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)
        let analyticsViewModel = EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
        let category = analyticsViewModel.displayedSlicesSortedByAmount(for: .categories).first?.category ?? .defaultValue

        return NavigationStack {
            EventSubcategoryAnalyticsView(
                category: category,
                data: viewModel.eventAnalyticsData,
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventSubcategoryAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventSubcategoryAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

