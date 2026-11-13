//
//  EventAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftData
import SwiftUI

/// Экран аналитики события с сводными данными и графиками.
struct EventAnalyticsView: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var selectedMetric: EventAnalyticsMetric = .summary
    @State private var isShowingExpensesMap = false

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String

    // MARK: - Инициализация

    /// Создает экран аналитики.
    /// - Parameters:
    ///   - data: Аналитические данные события.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(data: EventCategoryAnalyticsData, screenContextSubtitle: String) {
        self.viewModel = EventAnalyticsViewModel(data: data)
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        eventAnalyticsList
            .navigationTitle(.analytics)
            .navigationSubtitle(screenContextSubtitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !ExpenseMapItem.items(for: viewModel.data.expenses).isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingExpensesMap = true
                        } label: {
                            Image(systemName: "map")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingExpensesMap) {
                EventExpensesMapView(
                    expenses: viewModel.data.expenses,
                    screenContextSubtitle: screenContextSubtitle
                )
            }
    }

    // MARK: - Основной контент

    private var eventAnalyticsList: some View {
        List {
            metricHeader
            if viewModel.hasAnalytics(for: selectedMetric) {
                selectedMetricBody
            } else {
                emptyAnalyticsContent
            }
        }
    }

    @ViewBuilder
    private var selectedMetricBody: some View {
        switch selectedMetric {
        case .summary:
            EventAnalyticsSummaryBody(viewModel: viewModel)
        case .days:
            EventAnalyticsDaysBody(
                viewModel: viewModel,
                screenContextSubtitle: screenContextSubtitle
            )
        case .categories:
            EventAnalyticsCategoriesBody(
                viewModel: viewModel,
                screenContextSubtitle: screenContextSubtitle
            )
        }
    }

    private var emptyAnalyticsContent: some View {
        EmptyStateView(
            icon: "chart.xyaxis.line",
            title: .analyticsEmptyState
        )
        .listRowBackground(Color.clear)
    }

    // MARK: - Секции

    private var metricHeader: some View {
        Section {
            VStack(spacing: 14) {
                Picker(selection: $selectedMetric) {
                    ForEach(EventAnalyticsMetric.allCases) { metric in
                        if viewModel.hasAnalytics(for: metric) {
                            Text(metric.localizedResource).tag(metric)
                        }
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMetric) {
                    haptics.trigger(.tap)
                }
                .listRowSeparator(.hidden)
                
                if viewModel.hasAnalytics(for: selectedMetric) {
                    selectedMetricHeader
                }
            }
        }
    }
    
    @ViewBuilder
    private var selectedMetricHeader: some View {
        switch selectedMetric {
        case .summary:
            EventAnalyticsSummaryHeader(viewModel: viewModel)
        case .days:
            EventAnalyticsDaysHeader(viewModel: viewModel)
        case .categories:
            EventAnalyticsCategoriesHeader(viewModel: viewModel)
        }
    }
}

// MARK: - Превью

extension EventAnalyticsView {
    fileprivate static func makePreview(forTrip: Bool, includeExpenses: Bool) -> some View {
        let preview = ExpenseMapPreviewData(forTrip: forTrip, includeExpenses: includeExpenses)

        return NavigationStack {
            EventAnalyticsView(data: preview.analyticsData, screenContextSubtitle: preview.screenContextSubtitle)
        }
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
    }
}

#Preview("For Trip") {
    EventAnalyticsView.makePreview(forTrip: true, includeExpenses: true)
}

#Preview("For Location") {
    EventAnalyticsView.makePreview(forTrip: false, includeExpenses: true)
}

#Preview("Empty") {
    EventAnalyticsView.makePreview(forTrip: false, includeExpenses: false)
}
