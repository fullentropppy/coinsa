//
//  EventAnalyticsSummaryBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import SwiftUI

/// Тело вкладки сводной аналитики события.
struct EventAnalyticsSummaryBody: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает тело вкладки сводной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Тело View

    var body: some View {
        summaryContent
    }

    // MARK: - Основной контент

    private var summaryContent: some View {
        Group {
            summaryExpensesSection
        }
    }

    // MARK: - Секции

    private var summaryExpensesSection: some View {
        Section(.analyticsSummaryExpenses) {
            summaryExpensesCountRow
            if let peakTime = viewModel.peakTime {
                summaryTimeOfDayRow(peakTime)
            }
            if let largestExpense = viewModel.largestExpense {
                summaryLargestExpenseRow(largestExpense)
            }
        }
    }

    // MARK: - Компоненты

    private var summaryExpensesCountRow: some View {
        summaryRowHeader(icon: Expense.primaryIcon, title: .analyticsSummaryTotalExpenses) {
            Text(viewModel.totalExpensesCount.formatted())
        }
    }

    private func summaryTimeOfDayRow(_ data: EventDaySegmentAnalyticsData) -> some View {
        summaryRowHeader(icon: data.timeOfDay.primaryIcon, title: .analyticsSummaryPeakTime) {
            Text(data.timeOfDay.localizedResource)
        }
    }

    private func summaryLargestExpenseRow(_ expense: Expense) -> some View {
        NavigationLink {
            ExpenseDetailView(expense)
        } label: {
            VStack(spacing: 14) {
                summaryRowHeader(icon: "dollarsign", title: .analyticsSummaryLargestExpense) {
                    DateLabel(expense.civilDateTime)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: expense.category.primaryIcon)
                                .imageScale(.small)
                                .frame(width: 20)
                            Text(expense.category.localizedResource)
                                .font(.footnote)
                        }
                        HStack {
                            Image(systemName: expense.subcategory.primaryIcon)
                                .imageScale(.small)
                                .frame(width: 20)
                            Text(expense.subcategory.localizedResource)
                                .font(.footnote)
                        }
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    AmountStack(
                        baseAmount: expense.baseAmount,
                        baseCurrency: viewModel.baseCurrency,
                        expenseAmount: expense.amount(in: .location),
                        expenseCurrency: expense.expenseCurrency
                    )
                }
            }
        }
    }

    private func summaryRowHeader<Content: View>(
        icon: String,
        title: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(title)
            Spacer()
            content()
        }
    }
}

// MARK: - Превью

private extension EventAnalyticsSummaryBody {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsSummaryBody(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsSummaryBody.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsSummaryBody.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
