//
//  MajorTimeZone+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone: LabelProviding {
    var labelSyle: LabelView.Style {
        .withText(title: localizedResource, text: gmtOffsetDisplay)
    }
}
