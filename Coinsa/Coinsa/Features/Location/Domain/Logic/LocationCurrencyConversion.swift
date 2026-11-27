//
//  LocationCurrencyConversion.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

/// Пересчет домашних итогов в валюту локации без повторного применения корректировки.
nonisolated struct LocationCurrencyConversion: Equatable {
    // MARK: - Свойства

    let rateLocationToHome: Double

    // MARK: - Инициализация

    /// Фиксирует сохраненный курс локации для согласованного пересчета итогов.
    /// - Parameter rateLocationToHome: Количество единиц домашней валюты за единицу валюты локации.
    init(rateLocationToHome: Double) {
        self.rateLocationToHome = rateLocationToHome
    }

    // MARK: - Методы

    /// Переводит домашнюю сумму без промежуточного округления.
    /// - Parameter amount: Сумма в домашней валюте, уже учитывающая корректировки отдельных трат.
    /// - Returns: Эквивалент в валюте локации; при некорректном курсе или результате возвращает 0.
    func locationAmount(forHomeAmount amount: Double) -> Double {
        guard amount.isFinite, rateLocationToHome.isFinite, rateLocationToHome > 0 else { return 0 }
        let result = amount / rateLocationToHome
        return result.isFinite ? result : 0
    }
}
