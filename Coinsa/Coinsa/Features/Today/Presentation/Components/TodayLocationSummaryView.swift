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

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    let location: Location
    let locations: [Location]
    @Binding var selectedLocationID: UUID
    let summary: EventSummaryData
    let rateLocationToHome: Double

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
    init(
        location: Location,
        locations: [Location],
        selectedLocationID: Binding<UUID>,
        summary: EventSummaryData,
        rateLocationToHome: Double
    ) {
        self.location = location
        self.locations = locations
        _selectedLocationID = selectedLocationID
        self.summary = summary
        self.rateLocationToHome = rateLocationToHome
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
            contextContent(location: location)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 0)
                .fill(colorScheme == .light ? Material.regular : .thin)
        )
    }

    // MARK: - Компоненты

    private func contextContent(location: Location) -> some View {
        NavigationLink {
            LocationDetailView(location)
        } label: {
            HStack(alignment: .center) {
                if location.homeCurrency == location.locationCurrency {
                    Text("\(location.name) • \(location.trip?.name ?? "")")
                        .font(.subheadline)
                } else {
                    exchangeRatesContent(location: location)
                }
                Spacer()
                Image(systemName: Location.primaryIcon)
                    .imageScale(.small)
                    .font(.subheadline.weight(.semibold))
                    
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private func exchangeRatesContent(location: Location) -> some View {
        HStack {
            Image(systemName: "arrow.left.arrow.right")
                .imageScale(.small)
                .font(.subheadline.weight(.semibold))
            
            VStack(alignment: .leading) {
                Text(
                    .todayExchangeRateOf(
                        baseCurrencyCode: location.locationCurrencyCode,
                        rateBaseToQuote: rateLocationToHome.numberFormat(fractionLength: 4),
                        quoteCurrencyCode: location.trip?.baseCurrencyCode ?? ""
                    )
                )
                Text(
                    .todayExchangeRateOf(
                        baseCurrencyCode: location.trip?.baseCurrencyCode ?? "",
                        rateBaseToQuote: rateHomeToLocation.numberFormat(fractionLength: 4),
                        quoteCurrencyCode: location.locationCurrencyCode
                    )
                )
            }
            .font(.caption)
        }
    }
}
