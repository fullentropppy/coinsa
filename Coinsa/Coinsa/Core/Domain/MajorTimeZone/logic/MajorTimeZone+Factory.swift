//
//  MajorTimeZone+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

extension MajorTimeZone {
    static func from(_ indentifier: String) -> MajorTimeZone {
        MajorTimeZone(rawValue: indentifier) ?? .defaultValue
    }
}
