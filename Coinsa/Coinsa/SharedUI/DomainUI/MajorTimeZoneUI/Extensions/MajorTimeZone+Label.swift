//
//  MajorTimeZone+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone: LabelProviding {
    /// Стиль метки для часового пояса (текст со смещением GMT и названием).
    var labelSyle: LabelView.Style {
        .withText(title: localizedResource, text: gmtOffsetDisplay)
    }
}
