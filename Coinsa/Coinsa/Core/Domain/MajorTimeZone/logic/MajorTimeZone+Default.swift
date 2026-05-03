//
//  MajorTimeZone+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

extension MajorTimeZone {
    /// Часовой пояс по умолчанию (Москва).
    static var defaultValue: MajorTimeZone { MajorTimeZone.moscow }
    
    /// Идентификатор часового пояса по умолчанию (Europe/Moscow).
    static var defaultIdentifier: String { defaultValue.id }
}
