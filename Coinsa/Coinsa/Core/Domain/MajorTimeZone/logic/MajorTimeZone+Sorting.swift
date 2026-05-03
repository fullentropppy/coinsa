//
//  MajorTimeZone+Sorting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone {
    /// Все часовые пояса, отсортированные по смещению от GMT.
    static var allCasesSortedByGMT: [MajorTimeZone] {
        allCases.sorted {
            let offset1 = $0.gmtOffsetSeconds
            let offset2 = $1.gmtOffsetSeconds
            return offset1 < offset2
        }
    }
}
