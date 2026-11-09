//
//  EventAnalyticsDaysBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import SwiftUI

/// Тело вкладки дневной аналитики расходов события.
struct EventAnalyticsDaysBody: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String

    // MARK: - Инициализация

    /// Создает тело вкладки дневной аналитики.
    /// - Parameters:
    ///   - viewModel: ViewModel аналитики события.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(viewModel: EventAnalyticsViewModel, screenContextSubtitle: String) {
        self.viewModel = viewModel
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        daysContent
    }

    // MARK: - Основной контент

    private var daysContent: some View {
        Group {
            dailyExpenseChartSection
            dailyExpensesSection
        }
    }

    // MARK: - Секции

    private var dailyExpenseChartSection: some View {
        Section {
            EventDailyExpenseChart(viewModel: viewModel)
        }
        .padding(.vertical, 12)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var dailyExpensesSection: some View {
        Section {
            ForEach(viewModel.summaryExpenseChartPoints) { point in
                if point.homeAmount > 0 {
                    dailyExpenseRow(point)
                }
            }
        }
    }

    // MARK: - Компоненты

    private func dailyExpenseRow(_ point: EventDailyExpenseAnalyticsData) -> some View {
        NavigationLink {
            EventDayExpensesView(
                date: point.date,
                data: viewModel.data,
                screenContextSubtitle: screenContextSubtitle
            )
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    DateLabel(point.date.startOfDay, withTime: false, using: .utc)
                    CountLabel.secondarySmall(
                        point.expenseCount,
                        icon: Expense.primaryIcon
                    )
                }
                .frame(maxHeight: .infinity, alignment: .topLeading)
                Spacer()
                AmountStack(
                    homeAmount: point.homeAmount,
                    homeCurrency: viewModel.homeCurrency,
                    expenseAmount: point.locationAmount,
                    expenseCurrency: viewModel.locationCurrency
                )
            }
        }
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let viewModel = TripDetailViewModel(trip: trip)

    NavigationStack {
        List {
            EventAnalyticsDaysBody(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData),
                screenContextSubtitle: trip.screenContextSubtitle
            )
        }
    }
}
