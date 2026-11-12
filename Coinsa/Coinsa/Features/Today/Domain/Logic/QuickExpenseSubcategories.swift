//
//  QuickExpenseSubcategories.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

/// Подбор быстрых подкатегорий по количеству трат в локации.
enum QuickExpenseSubcategories {
    static func select(from subcategories: [ExpenseSubcategory]) -> [ExpenseSubcategory] {
        let defaults: [ExpenseSubcategory] = [.snack, .publicTransport, .entertainment]
        let counts = subcategories.reduce(into: [ExpenseSubcategory: Int]()) {
            $0[$1, default: 0] += 1
        }

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
