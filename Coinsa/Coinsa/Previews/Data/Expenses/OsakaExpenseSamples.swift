//
//  OsakaExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Синтетические траты Осаки без привязки к хранилищу.
enum OsakaExpenseSamples {
    /// Возвращает примеры относительно календарного начала локации в UTC-представлении.
    /// - Parameter startDate: Первый день локации в формате хранения PlainDate.
    static func makeSamples(startDate: Date) -> [ExpensePreviewSample] {
        return [
            ExpensePreviewSample(
                date: startDate.adding(hours: 11, minutes: 49, using: .utc),
                homeAmount: 2099,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.6849,
                longitude: 135.5023,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 15, minutes: 20, using: .utc),
                homeAmount: 201,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 34.6855,
                longitude: 135.5018,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 16, minutes: 16, using: .utc),
                homeAmount: 2720,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .lunch,
                latitude: 34.6682,
                longitude: 135.5023,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 17, minutes: 39, using: .utc),
                homeAmount: 290,
                category: .miscellaneous,
                subcategory: .donation,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 34.6846,
                longitude: 135.5026,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 21, minutes: 15, using: .utc),
                homeAmount: 290,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .snack,
                latitude: 34.6685,
                longitude: 135.5020,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 10, minutes: 27, using: .utc),
                homeAmount: 1556,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 34.6688,
                longitude: 135.5028,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 14, minutes: 32, using: .utc),
                homeAmount: 4010,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 34.6680,
                longitude: 135.5025,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 18, minutes: 49, using: .utc),
                homeAmount: 1900.04,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.6842,
                longitude: 135.5030,
                horizontalAccuracy: 22.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 20, minutes: 59, using: .utc),
                homeAmount: 1500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 34.6683,
                longitude: 135.5026,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 10, minutes: 15, using: .utc),
                homeAmount: 2068,
                category: .food,
                subcategory: .breakfast,
                latitude: 34.6687,
                longitude: 135.5022,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 13, minutes: 13, using: .utc),
                homeAmount: 2400,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 34.6840,
                longitude: 135.5032,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 14, minutes: 20, using: .utc),
                homeAmount: 309.06,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 34.6853,
                longitude: 135.5020,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 19, using: .utc),
                homeAmount: 5200,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 34.6681,
                longitude: 135.5029,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 22, using: .utc),
                homeAmount: 2095,
                category: .food,
                subcategory: .dinner,
                latitude: 34.6684,
                longitude: 135.5024,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 5, minutes: 1, using: .utc),
                homeAmount: 5252.9,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 34.6850,
                longitude: 135.5015,
                horizontalAccuracy: 30.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 7, minutes: 26, using: .utc),
                homeAmount: 4520,
                category: .food,
                subcategory: .breakfast,
                latitude: 34.6686,
                longitude: 135.5021,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 8, minutes: 44, using: .utc),
                homeAmount: 6270,
                paymentMethod: .card,
                exchangeAdjustment: 5.5,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 34.6844,
                longitude: 135.5028,
                horizontalAccuracy: 22.0
            )
        ]
    }
}
