//
//  SaintPetersburgExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Синтетические траты Санкт-Петербурга без привязки к хранилищу.
enum SaintPetersburgExpenseSamples {
    /// Возвращает примеры относительно календарного начала локации в UTC-представлении.
    /// - Parameter startDate: Первый день локации в формате хранения PlainDate.
    static func makeSamples(startDate: Date) -> [ExpensePreviewSample] {
        return [
            ExpensePreviewSample(
                date: startDate.adding(hours: 10, minutes: 19, using: .utc),
                homeAmount: 2990,
                paymentMethod: .card,
                category: .food,
                subcategory: .breakfast,
                latitude: 59.9386,
                longitude: 30.3141,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 13, using: .utc),
                homeAmount: 950,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 59.9398,
                longitude: 30.3146,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 16, minutes: 17, using: .utc),
                homeAmount: 2400,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 59.9398,
                longitude: 30.3159,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 21, minutes: 33, using: .utc),
                homeAmount: 1800,
                paymentMethod: .card,
                category: .food,
                subcategory: .dinner,
                latitude: 59.9389,
                longitude: 30.3138,
                horizontalAccuracy: 14.0
            )
        ]
    }
}
