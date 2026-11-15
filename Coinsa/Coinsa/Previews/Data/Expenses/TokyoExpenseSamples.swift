//
//  TokyoExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Синтетические траты Токио без привязки к хранилищу.
enum TokyoExpenseSamples {
    /// Возвращает примеры относительно календарного начала локации в UTC-представлении.
    /// - Parameter startDate: Первый день локации в формате хранения PlainDate.
    static func makeSamples(startDate: Date) -> [ExpensePreviewSample] {
        return [
            ExpensePreviewSample(
                date: startDate.adding(hours: 8, minutes: 45, using: .utc),
                homeAmount: 2300,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.6595,
                longitude: 139.7004,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 13, minutes: 20, using: .utc),
                homeAmount: 2116.4,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 35.6812,
                longitude: 139.7671,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 13, minutes: 58, using: .utc),
                homeAmount: 120,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6814,
                longitude: 139.7663,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 17, minutes: 11, using: .utc),
                homeAmount: 3200,
                category: .leisure,
                subcategory: .entertainment,
                latitude: 35.6594,
                longitude: 139.7005,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 23, minutes: 31, using: .utc),
                homeAmount: 1992,
                category: .food,
                subcategory: .dinner,
                latitude: 35.6601,
                longitude: 139.6998,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 10, minutes: 4, using: .utc),
                homeAmount: 140,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.6815,
                longitude: 139.7665,
                horizontalAccuracy: 8.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 12, minutes: 12, using: .utc),
                homeAmount: 2120,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .food,
                subcategory: .lunch,
                latitude: 35.6598,
                longitude: 139.7002,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 18, minutes: 31, using: .utc),
                homeAmount: 8902,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .leisure,
                subcategory: .activity,
                latitude: 35.6603,
                longitude: 139.6995,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 20, minutes: 40, using: .utc),
                homeAmount: 8150,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 35.6593,
                longitude: 139.7006,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 23, using: .utc),
                homeAmount: 1220,
                category: .medicine,
                subcategory: .medication,
                comment: PreviewExpenseComment.pharmacy.rawValue,
                latitude: 35.6605,
                longitude: 139.6992,
                horizontalAccuracy: 22.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 8, minutes: 24, using: .utc),
                homeAmount: 240,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6813,
                longitude: 139.7664,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 12, minutes: 01, using: .utc),
                homeAmount: 3098.4,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.6597,
                longitude: 139.7003,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 15, minutes: 58, using: .utc),
                homeAmount: 3409.72,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 35.7147,
                longitude: 139.7967,
                horizontalAccuracy: 30.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 17, using: .utc),
                homeAmount: 312,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6816,
                longitude: 139.7662,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 20, minutes: 52, using: .utc),
                homeAmount: 12091.07,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 35.6590,
                longitude: 139.7008,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 11, minutes: 15, using: .utc),
                homeAmount: 887.01,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 35.6602,
                longitude: 139.6994,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 12, minutes: 53, using: .utc),
                homeAmount: 2590,
                category: .food,
                subcategory: .lunch,
                latitude: 35.6599,
                longitude: 139.7001,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 14, minutes: 11, using: .utc),
                homeAmount: 1450,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 35.6604,
                longitude: 139.6996,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 16, minutes: 40, using: .utc),
                homeAmount: 90,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6812,
                longitude: 139.7666,
                horizontalAccuracy: 8.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 19, minutes: 28, using: .utc),
                homeAmount: 2500,
                category: .shopping,
                subcategory: .cosmetics,
                latitude: 35.6592,
                longitude: 139.7007,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 23, minutes: 5, using: .utc),
                homeAmount: 1841.98,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 35.6600,
                longitude: 139.7000,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 10, minutes: 15, using: .utc),
                homeAmount: 1882,
                category: .food,
                subcategory: .breakfast,
                latitude: 35.6596,
                longitude: 139.7004,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 14, minutes: 19, using: .utc),
                homeAmount: 500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .taxi,
                latitude: 35.6810,
                longitude: 139.7670,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 14, minutes: 59, using: .utc),
                homeAmount: 1003.6,
                category: .miscellaneous,
                subcategory: .digitalService,
                latitude: 35.6606,
                longitude: 139.6991,
                horizontalAccuracy: 22.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 17, minutes: 30, using: .utc),
                homeAmount: 5902,
                paymentMethod: .card,
                exchangeAdjustment: 4.5,
                category: .leisure,
                subcategory: .tour,
                latitude: 35.7149,
                longitude: 139.7969,
                horizontalAccuracy: 35.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 5, hours: 19, minutes: 30, using: .utc),
                homeAmount: 2600,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 35.6601,
                longitude: 139.6999,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 20, minutes: 50, using: .utc),
                homeAmount: 202,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.6817,
                longitude: 139.7661,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 4, hours: 23, minutes: 42, using: .utc),
                homeAmount: 3850,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner,
                latitude: 35.6594,
                longitude: 139.7006,
                horizontalAccuracy: 14.0
            ),
        ]
    }
}
