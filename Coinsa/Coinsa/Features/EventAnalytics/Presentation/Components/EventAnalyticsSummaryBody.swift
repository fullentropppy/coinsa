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
            VStack(spacing: ViewLayout.Summary.sectionSpacing) {
                summaryRowHeader(icon: AppSymbols.dollarsign, title: .analyticsSummaryLargestExpense) {
                    DateLabel(expense.civilDateTime)
                }
                HStack {
                    VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
                        HStack {
                            AppIcon(expense.category.primaryIcon, style: .metadata)
                                .frame(width: ViewLayout.Label.formIconWidth)
                            Text(expense.category.localizedResource)
                                .font(.footnote)
                        }
                        HStack {
                            AppIcon(expense.subcategory.primaryIcon, style: .metadata)
                                .frame(width: ViewLayout.Label.formIconWidth)
                            Text(expense.subcategory.localizedResource)
                                .font(.footnote)
                        }
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    AmountStack(
                        homeAmount: expense.homeAmount,
                        homeCurrency: viewModel.homeCurrency,
                        expenseAmount: expense.amount(in: .expense),
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
            AppIcon(icon, style: .formLabel)
            Text(title)
            Spacer()
            content()
        }
    }
}

// MARK: - Превью

#Preview {
    let viewModel = TripDetailViewModel(
        trip: PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    )

    NavigationStack {
        List {
            EventAnalyticsSummaryBody(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
        }
    }
}
