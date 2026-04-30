//
//  Location+MajorTimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Location {
    var majorTimeZone: MajorTimeZone {
        MajorTimeZone.from(timeZoneID)
    }
}
