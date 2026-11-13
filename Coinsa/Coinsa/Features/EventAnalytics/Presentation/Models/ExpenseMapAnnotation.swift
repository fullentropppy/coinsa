//
//  ExpenseMapAnnotation.swift
//  Coinsa
//

import MapKit

/// Аннотация с неизменяемым снимком траты вместо ссылки на постоянную модель.
final class ExpenseMapAnnotation: NSObject, MKAnnotation {
    let item: ExpenseMapItem

    var coordinate: CLLocationCoordinate2D {
        item.coordinate.coreLocationCoordinate
    }

    init(item: ExpenseMapItem) {
        self.item = item
        super.init()
    }
}
