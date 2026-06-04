//
//  ExpenseSubcategory+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.06.2026.
//

import Foundation

extension ExpenseSubcategory: LabelProviding {
    /// Стиль метки для подкатегории траты (иконка с фиксированной шириной).
    var labelSyle: LabelView.Style {
        .withIcon(title: localizedResource, icon: primaryIcon, iconWidth: 28)
    }
}
