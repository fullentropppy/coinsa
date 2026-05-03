//
//  MajorTimeZone+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

extension MajorTimeZone {
    /// Создает часовой пояс по идентификатору.
    /// - Parameter indentifier: Идентификатор часового пояса IANA.
    /// - Returns: Часовой пояс или значение по умолчанию, если идентификатор не найден.
    static func from(_ indentifier: String) -> MajorTimeZone {
        MajorTimeZone(rawValue: indentifier) ?? .defaultValue
    }
}
