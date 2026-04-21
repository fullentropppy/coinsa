//
//  Location+MajorTimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension Location {
    var majorTimeZone: MajorTimeZone {
        MajorTimeZone.from(selectedTimeZoneIdentifier)
    }
}
