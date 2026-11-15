//
//  KyotoExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Синтетические траты Киото без привязки к хранилищу.
enum KyotoExpenseSamples {
    /// Возвращает примеры относительно календарного начала локации в UTC-представлении.
    /// - Parameter startDate: Первый день локации в формате хранения PlainDate.
    static func makeSamples(startDate: Date) -> [ExpensePreviewSample] {
        return [
            ExpensePreviewSample(
                date: startDate.adding(hours: 8, minutes: 14, using: .utc),
                homeAmount: 6250,
                category: .transport,
                subcategory: .train,
                comment: PreviewExpenseComment.train.rawValue,
                latitude: 34.9853,
                longitude: 135.7593,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 9, using: .utc),
                homeAmount: 1200,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.snacks.rawValue,
                latitude: 35.0116,
                longitude: 135.7681,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 10, minutes: 19, using: .utc),
                homeAmount: 3509.9,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .entertainment,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 35.0394,
                longitude: 135.7287,
                horizontalAccuracy: 25.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(hours: 10, minutes: 54, using: .utc),
                homeAmount: 2500.05,
                category: .food,
                subcategory: .lunch,
                latitude: 35.0114,
                longitude: 135.7684,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 13, minutes: 14, using: .utc),
                homeAmount: 5209.6,
                category: .leisure,
                subcategory: .tour,
                latitude: 34.9948,
                longitude: 135.7585,
                horizontalAccuracy: 30.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 14, minutes: 20, using: .utc),
                homeAmount: 120,
                category: .medicine,
                subcategory: .medication,
                latitude: 35.0118,
                longitude: 135.7678,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 14, minutes: 57, using: .utc),
                homeAmount: 2691,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 35.0115,
                longitude: 135.7683,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 16, minutes: 50, using: .utc),
                homeAmount: 890,
                category: .leisure,
                subcategory: .park,
                comment: PreviewExpenseComment.temple.rawValue,
                latitude: 34.9977,
                longitude: 135.7852,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 19, minutes: 10, using: .utc),
                homeAmount: 212,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.0111,
                longitude: 135.7686,
                horizontalAccuracy: 10.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 1, hours: 20, minutes: 19, using: .utc),
                homeAmount: 1620.18,
                category: .shopping,
                subcategory: .souvenirs,
                comment: PreviewExpenseComment.souvenirs.rawValue,
                latitude: 35.0117,
                longitude: 135.7680,
                horizontalAccuracy: 16.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 9, minutes: 36, using: .utc),
                homeAmount: 2906.7,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.0113,
                longitude: 135.7685,
                horizontalAccuracy: 14.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 10, minutes: 53, using: .utc),
                homeAmount: 1105,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.bus.rawValue,
                latitude: 34.9856,
                longitude: 135.7590,
                horizontalAccuracy: 12.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 14, minutes: 32, using: .utc),
                homeAmount: 2000.05,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.9945,
                longitude: 135.7588,
                horizontalAccuracy: 22.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 16, minutes: 50, using: .utc),
                homeAmount: 2012,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 35.0119,
                longitude: 135.7677,
                horizontalAccuracy: 20.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 20, minutes: 15, using: .utc),
                homeAmount: 29020,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .electronics,
                latitude: 35.0110,
                longitude: 135.7687,
                horizontalAccuracy: 15.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 22, minutes: 28, using: .utc),
                homeAmount: 3040.84,
                category: .food,
                subcategory: .dinner,
                latitude: 35.0116,
                longitude: 135.7682,
                horizontalAccuracy: 18.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 9, using: .utc),
                homeAmount: 706,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.0114,
                longitude: 135.7684,
                horizontalAccuracy: 13.0
            ),
            ExpensePreviewSample(
                date: startDate.adding(days: 2, hours: 10, minutes: 12, using: .utc),
                homeAmount: 706,
                category: .transport,
                subcategory: .train,
                comment: PreviewExpenseComment.train.rawValue,
                latitude: 34.9855,
                longitude: 135.7591,
                horizontalAccuracy: 20.0
            )
        ]
    }
}
