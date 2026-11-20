//
//  ExpenseMapAnnotation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import MapKit

/// Аннотация с неизменяемым снимком траты вместо ссылки на постоянную модель.
final class ExpenseMapAnnotation: NSObject, MKAnnotation {
    // MARK: - Хранимые свойства

    let item: ExpenseMapItem

    // MARK: - Вычисляемые свойства

    var coordinate: CLLocationCoordinate2D {
        item.coordinate.coreLocationCoordinate
    }

    // MARK: - Инициализация

    /// Создает аннотацию карты для переданного элемента расходов.
    init(item: ExpenseMapItem) {
        self.item = item
        super.init()
    }
}
