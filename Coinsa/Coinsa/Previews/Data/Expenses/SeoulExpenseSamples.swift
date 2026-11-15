//
//  SeoulExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Синтетические траты Сеула без привязки к хранилищу.
enum SeoulExpenseSamples {
    /// Возвращает примеры относительно календарного начала локации в UTC-представлении.
    /// - Parameter startDate: Первый день локации в формате хранения PlainDate.
    static func makeSamples(startDate: Date) -> [ExpensePreviewSample] {
        return [
            ExpensePreviewSample(
                date: startDate.adding(hours: 8, minutes: 15, using: .utc),
                homeAmount: 3205.92,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 37.5665,
                longitude: 126.9780,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 9, minutes: 14, using: .utc),
                homeAmount: 312,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 37.5700,
                longitude: 126.9824,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 14, minutes: 12, using: .utc),
                homeAmount: 2300,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 37.5668,
                longitude: 126.9783,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 15, minutes: 53, using: .utc),
                homeAmount: 150,
                category: .miscellaneous,
                subcategory: .bankFees,
                latitude: 37.5660,
                longitude: 126.9775,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 16, minutes: 14, using: .utc),
                homeAmount: 924.13,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 37.5672,
                longitude: 126.9788,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 19, minutes: 49, using: .utc),
                homeAmount: 9200.2,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .jewelry,
                latitude: 37.5663,
                longitude: 126.9778,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 21, minutes: 10, using: .utc),
                homeAmount: 2910,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5666,
                longitude: 126.9782,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 9, minutes: 11, using: .utc),
                homeAmount: 2450,
                category: .food,
                subcategory: .breakfast,
                latitude: 37.5664,
                longitude: 126.9785,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 10, minutes: 15, using: .utc),
                homeAmount: 292.4,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 37.5698,
                longitude: 126.9822,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 13, minutes: 13, using: .utc),
                homeAmount: 1043,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 37.5795,
                longitude: 126.9770,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 15, minutes: 16, using: .utc),
                homeAmount: 1687,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 37.5667,
                longitude: 126.9781,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 16, minutes: 37, using: .utc),
                homeAmount: 300,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5702,
                longitude: 126.9826,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 19, minutes: 50, using: .utc),
                homeAmount: 2540.14,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5669,
                longitude: 126.9779,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 11, using: .utc),
                homeAmount: 2051.51,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 37.5662,
                longitude: 126.9786,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 12, minutes: 7, using: .utc),
                homeAmount: 199.3,
                paymentMethod: .card,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5701,
                longitude: 126.9825,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 14, minutes: 41, using: .utc),
                homeAmount: 42900,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .electronics,
                latitude: 37.5658,
                longitude: 126.9772,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 17, minutes: 59, using: .utc),
                homeAmount: 14200,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .activity,
                latitude: 37.5660,
                longitude: 126.9775,
                horizontalAccuracy: 22.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 19, minutes: 40, using: .utc),
                homeAmount: 1250,
                paymentMethod: .card,
                exchangeAdjustment: 6,
                category: .miscellaneous,
                subcategory: .laundry,
                latitude: 37.5670,
                longitude: 126.9787,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 22, minutes: 1, using: .utc),
                homeAmount: 1940.2,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5665,
                longitude: 126.9784,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 23, minutes: 44, using: .utc),
                homeAmount: 1001,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 37.5673,
                longitude: 126.9789,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 10, minutes: 14, using: .utc),
                homeAmount: 2046,
                category: .food,
                subcategory: .breakfast,
                latitude: 37.5663,
                longitude: 126.9783,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 11, minutes: 35, using: .utc),
                homeAmount: 199,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5703,
                longitude: 126.9827,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 3, hours: 15, minutes: 42, using: .utc),
                homeAmount: 765,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .bankFees,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 37.5664,
                longitude: 126.9776,
                horizontalAccuracy: 20.0
            )
        ]
    }
}
