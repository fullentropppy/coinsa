//
//  TodayLocationSummaryView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftUI
import SwiftData

/// Сводка выбранной локации, переключатель и справочный курс.
struct TodayLocationSummaryView: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    private let onShowLocation: () -> Void
    private let onShowAnalytics: () -> Void
    
    let location: Location
    let locations: [Location]
    let summary: EventSummaryData
    let rateLocationToHome: Double
    let hasDayExpenses: Bool
    
    @Binding var selectedLocationID: UUID

    // MARK: - Вычисляемые свойства

    private var rateHomeToLocation: Double {
        rateLocationToHome > 0 ? 1 / rateLocationToHome : 0
    }

    // MARK: - Инициализация

    /// Создает сводку локации с переключателем и справочным курсом.
    /// - Parameters:
    ///   - location: Выбранная локация для сводки и перехода на детальный экран.
    ///   - locations: Доступные локации в порядке отображения переключателя.
    ///   - selectedLocationID: Привязка выбранной локации; изменение переключателя передает новый идентификатор экрану.
    ///   - summary: Подготовленные суммы бюджета, расходов и остатка выбранной локации.
    ///   - rateLocationToHome: Справочный курс в единицах домашней валюты за единицу валюты локации.
    ///   - hasDayExpenses: Есть ли у выбранной локации траты за указанный день.
    ///   - onShowLocation: Переход к выбранной локации.
    ///   - onShowAnalytics: Переход к дневной аналитике выбранной локации.
    init(
        location: Location,
        locations: [Location],
        selectedLocationID: Binding<UUID>,
        summary: EventSummaryData,
        rateLocationToHome: Double,
        hasDayExpenses: Bool,
        onShowLocation: @escaping () -> Void,
        onShowAnalytics: @escaping () -> Void
    ) {
        self.location = location
        self.locations = locations
        _selectedLocationID = selectedLocationID
        self.summary = summary
        self.rateLocationToHome = rateLocationToHome
        self.hasDayExpenses = hasDayExpenses
        self.onShowLocation = onShowLocation
        self.onShowAnalytics = onShowAnalytics
    }

    // MARK: - Тело View

    var body: some View {
        Section {
            VStack(spacing: ViewLayout.Summary.sectionSpacing) {
                if locations.count > 1 {
                    Picker(selection: $selectedLocationID) {
                        ForEach(locations, id: \.id) { location in
                            Text(location.name)
                                .tag(location.id)
                        }
                    } label: {
                        EmptyView()
                    }
                    .onChange(of: selectedLocationID) {
                        haptics.trigger(.tap)
                    }
                    .pickerStyle(.segmented)
                }

                EventSummaryView(
                    data: summary,
                    showsHeader: false,
                    showsBudgetIfZero: location.hasBudget
                )
            }
            HStack {
                DetailNavigationButton.location(action: onShowLocation)
                if hasDayExpenses {
                    DetailNavigationButton.analytics(action: onShowAnalytics)
                }
            }
        } footer: {
            if location.locationCurrency != location.homeCurrency {
                exchangeRates
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 0)
                .fill(.regularMaterial)
        )
    }

    // MARK: - Компоненты

    private var exchangeRates: some View {
        HStack{
            Text(
                .todayExchangeRateOf(
                    baseCurrencyCode: location.locationCurrencyCode,
                    rateBaseToQuote: rateLocationToHome.numberFormat(fractionLength: 4),
                    quoteCurrencyCode: location.trip?.baseCurrencyCode ?? ""
                )
            )
            DotDivider()
            Text(
                .todayExchangeRateOf(
                    baseCurrencyCode: location.trip?.baseCurrencyCode ?? "",
                    rateBaseToQuote: rateHomeToLocation.numberFormat(fractionLength: 4),
                    quoteCurrencyCode: location.locationCurrencyCode
                )
            )
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .center)
    }
}
