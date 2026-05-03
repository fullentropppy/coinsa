//
//  ExpenseCategory+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension ExpenseCategory: LabelProviding {
    /// Стиль метки для категории траты (иконка с фиксированной шириной).
    var labelSyle: LabelView.Style {
        .withIcon(title: localizedResource, icon: primaryIcon, iconWidth: 28)
    }
}
