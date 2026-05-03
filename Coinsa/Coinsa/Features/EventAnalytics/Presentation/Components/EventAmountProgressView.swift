//
//  EventAmountrealizationView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.04.2026.
//

import SwiftUI

/// Представление прогресса выполнения плана по суммам (план vs факт) для события.
struct EventAmountProgressView<Header: View>: View {
    // MARK: - Хранимые свойства
    
    private let plannedBaseAmount: Double
    private let actualBaseAmount: Double
    private let baseCurrency: Currency
    private let plannedLocalAmount: Double?
    private let actualLocalAmount: Double?
    private let localCurrency: Currency?
    private let showsPlannedIfZero: Bool
    private let header: () -> Header
    
    // MARK: - Вычисляемые свойства
    
    private var showsPlan: Bool {
        plannedBaseAmount > 0 || showsPlannedIfZero
    }
    
    private var baseAmountBalance: Double {
        plannedBaseAmount - actualBaseAmount
    }
    
    private var localAmountBalance: Double? {
        if let plannedLocalAmount, let actualLocalAmount {
            plannedLocalAmount - actualLocalAmount
        } else {
            nil
        }
    }
    
    private var progress: Double {
        plannedBaseAmount > 0 ? baseAmountBalance / plannedBaseAmount : 0
    }
    
    // MARK: - Инициализация
    
    /// Создает представление прогресса выполнения плана.
    /// - Parameters:
    ///   - plannedBaseAmount: Плановая сумма в основной валюте.
    ///   - baseActualAmount: Фактическая сумма в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - localPlannedAmount: Плановая сумма в локальной валюте (опционально).
    ///   - localActualAmount: Фактическая сумма в локальной валюте (опционально).
    ///   - localCurrency: Локальная валюта (опционально).
    ///   - showsPlannedIfZero: Отображать плановую сумму если отсутствует. По умолчанию `false`.
    ///   - header: Замыкание для создания кастомного заголовка.
    init(
        plannedBaseAmount: Double,
        baseActualAmount: Double,
        baseCurrency: Currency,
        localPlannedAmount: Double? = nil,
        localActualAmount: Double? = nil,
        localCurrency: Currency? = nil,
        showsPlannedIfZero: Bool = false,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.plannedBaseAmount = plannedBaseAmount
        self.actualBaseAmount = baseActualAmount
        self.baseCurrency = baseCurrency
        self.plannedLocalAmount = localPlannedAmount
        self.actualLocalAmount = localActualAmount
        self.localCurrency = localCurrency
        self.showsPlannedIfZero = showsPlannedIfZero
        self.header = header
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading) {
            titleContent
            progressBarContent
            summaryContent
        }
    }
    
    // MARK: - Компоненты
    
    private var titleContent: some View {
        HStack {
            header()
            if showsPlan {
                Spacer()
                Text(.amountBalancePersentage(balancePercent: progress.percentFormat()))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var progressBarContent: some View {
        if showsPlan {
            ProgressBar(currentValue: baseAmountBalance, maxValue: plannedBaseAmount, style: .positive)
        } else {
            ProgressBar(currentValue: 0, maxValue: 0, style: .negative)
        }
    }
    
    private var summaryContent: some View {
        VStack {
            if showsPlan {
                amountTextRow(
                    title: .amountPlan,
                    baseAmount: plannedBaseAmount,
                    localAmount: plannedLocalAmount
                )
            }
            
            amountTextRow(
                title: .amountActual,
                baseAmount: actualBaseAmount,
                localAmount: actualLocalAmount
            )
            
            if showsPlan {
                amountTextRow(
                    title: .amountBalance,
                    baseAmount: baseAmountBalance,
                    localAmount: localAmountBalance
                )
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    
    private func amountTextRow(
        title: LocalizedStringResource,
        baseAmount: Double,
        localAmount: Double?
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let localAmount, let localCurrency {
                Text(
                    .amountDuo(
                        localAmountBalance: localAmount.numberFormat(),
                        localCurrencyCode: localCurrency.code,
                        baseAmountBalance: baseAmount.numberFormat(),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            } else {
                Text(
                    .amountMono(
                        baseAmountBalance: baseAmount.numberFormat(),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            }
        }
    }
}

// MARK: - Превью

private extension EventAmountProgressView where Header == HStack<TupleView<(DotView, Text)>> {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        Form {
            Section {
                EventAmountProgressView(
                    plannedBaseAmount: 42000,
                    baseActualAmount: 22000,
                    baseCurrency: .defaultValue,
                    localPlannedAmount: 84000,
                    localActualAmount: 44000,
                    localCurrency: .jpy
                ) {
                    HStack {
                        ExpenseCategory.food.makeDot()
                        Text(ExpenseCategory.food.localizedResource)
                    }
                }
                
                EventAmountProgressView(
                    plannedBaseAmount: 42000,
                    baseActualAmount: 52000,
                    baseCurrency: .defaultValue,
                    localPlannedAmount: 84000,
                    localActualAmount: 104000,
                    localCurrency: .jpy
                ) {
                    HStack {
                        ExpenseCategory.food.makeDot()
                        Text(ExpenseCategory.food.localizedResource)
                    }
                }
                
                EventAmountProgressView(
                    plannedBaseAmount: 42000,
                    baseActualAmount: 32000,
                    baseCurrency: .defaultValue
                ) {
                    HStack {
                        ExpenseCategory.food.makeDot()
                        Text(ExpenseCategory.food.localizedResource)
                    }
                }
                
                EventAmountProgressView(
                    plannedBaseAmount: 0,
                    baseActualAmount: 22000,
                    baseCurrency: .defaultValue,
                    localPlannedAmount: 0,
                    localActualAmount: 44000,
                    localCurrency: .jpy
                ) {
                    HStack {
                        ExpenseCategory.food.makeDot()
                        Text(ExpenseCategory.food.localizedResource)
                    }
                }
                
                EventAmountProgressView(
                    plannedBaseAmount: 0,
                    baseActualAmount: 32000,
                    baseCurrency: .defaultValue
                ) {
                    HStack {
                        ExpenseCategory.food.makeDot()
                        Text(ExpenseCategory.food.localizedResource)
                    }
                }
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAmountProgressView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAmountProgressView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
