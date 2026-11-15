//
//  AppAppearance+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

extension AppAppearance: LabelProviding {
    /// Стиль метки для режима внешнего вида (иконка с фиксированной шириной).
    var labelStyle: ItemLabel.Style {
        .withIcon(title: localizedResource, icon: primaryIcon, iconWidth: ViewLayout.Label.formIconWidth)
    }
}
