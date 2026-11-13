//
//  QuickExpenseSubcategories.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

/// Подбор быстрых подкатегорий по количеству трат в локации.
enum QuickExpenseSubcategories {
    /// Подбирает быстрые подкатегории по истории трат локации.
    /// - Parameter subcategories: Подкатегории всех трат; каждое вхождение учитывается в частоте.
    /// - Returns: Три подкатегории по частоте использования с дополнением стандартными вариантами.
    static func select(from subcategories: [ExpenseSubcategory]) -> [ExpenseSubcategory] {
        let counts = subcategories.reduce(into: [ExpenseSubcategory: Int]()) {
            $0[$1, default: 0] += 1
        }
        return select(from: counts)
    }

    /// Подбирает быстрые подкатегории по уже подсчитанным частотам без повторного обхода истории.
    /// - Parameter counts: Количество трат каждой подкатегории; отсутствующие и неположительные значения не участвуют в рейтинге.
    /// - Returns: Три подкатегории; равные частоты разрешаются порядком `allCases`, свободные места дополняются стандартными вариантами.
    static func select(from counts: [ExpenseSubcategory: Int]) -> [ExpenseSubcategory] {
        let defaults: [ExpenseSubcategory] = [.snack, .publicTransport, .entertainment]

        let ranked = ExpenseSubcategory.allCases.enumerated()
            .filter { counts[$0.element, default: 0] > 0 }
            .sorted {
                let lhsCount = counts[$0.element, default: 0]
                let rhsCount = counts[$1.element, default: 0]
                return lhsCount == rhsCount ? $0.offset < $1.offset : lhsCount > rhsCount
            }
            .prefix(3)
            .map(\.element)

        var result = ranked
        
        for defaultSubcategory in defaults.dropFirst(ranked.count) {
            if !result.contains(defaultSubcategory) {
                result.append(defaultSubcategory)
            } else if let replacement = defaults.first(where: { !result.contains($0) }) {
                result.append(replacement)
            }
        }
        
        return result
    }
}
