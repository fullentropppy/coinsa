//
//  EventAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftUI

/// Экран аналитики события с сводными данными и графиками.
struct EventAnalyticsView: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var selectedMetric: EventAnalyticsMetric = .summary

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
    }

    // MARK: - Основной контент

    private var eventAnalyticsList: some View {
        List {
            metricPickerSection
            if viewModel.hasAnalytics(for: selectedMetric) {
                selectedMetricContent
            } else {
                emptyAnalyticsContent
            }
        }
    }

    @ViewBuilder
    private var selectedMetricContent: some View {
        switch selectedMetric {
        case .summary:
            EventAnalyticsSummaryView(viewModel: viewModel)
        case .days:
            EventAnalyticsDaysView(viewModel: viewModel)
        case .categories:
            EventAnalyticsCategoriesView(
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

    private var metricPickerSection: some View {
        Section {
            Picker("", selection: $selectedMetric) {
                ForEach(EventAnalyticsMetric.allCases) { metric in
                    Text(metric.localizedResource).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMetric) {
                haptics.trigger(.tap)
            }
            .listRowSeparator(.hidden)
        }
    }
}

// MARK: - Превью

extension EventAnalyticsView {
    fileprivate static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        forTrip: Bool = true,
        withSignificantData: Bool = true
    ) -> some View {
        let builder =
            PreviewBuilder
            .builder()
            .withScenario(.southKorea)
            .withExpenses(withSignificantData)

        let data = builder.buildData()

        let screenContextSubtitle: String
        let analyticsData: EventCategoryAnalyticsData

        if forTrip {
            let trip = builder.getTrip(from: data)
            let viewModel = TripDetailViewModel(trip: trip)
            screenContextSubtitle = trip.screenContextSubtitle
            analyticsData = viewModel.eventAnalyticsData
        } else {
            let location = builder.getLocation(from: data)
            let viewModel = LocationDetailViewModel(location: location)
            screenContextSubtitle = location.screenContextSubtitle
            analyticsData = viewModel.eventAnalyticsData
        }

        return NavigationStack {
            EventAnalyticsView(data: analyticsData, screenContextSubtitle: screenContextSubtitle)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Trip. Light - RU") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Trip. Dark - EN") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Location. Light - RU") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, forTrip: false)
}

#Preview("Location. Dark - EN") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, forTrip: false)
}

#Preview("Empty. Light - RU") {
    EventAnalyticsView.makePreview(
        locale: PreviewLocale.ru,
        colorScheme: .light,
        withSignificantData: false
    )
}

#Preview("Empty. Dark - EN") {
    EventAnalyticsView.makePreview(
        locale: PreviewLocale.en,
        colorScheme: .dark,
        withSignificantData: false
    )
}
