//
//  MajorTimeZone+Date.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension MajorTimeZone {
    /// Создает дату с учетом часового пояса.
    /// - Parameters:
    ///   - year: Год.
    ///   - month: Месяц (1...12).
    ///   - day: День (1...31).
    ///   - hour: Час (0...23).
    ///   - minute: Минута (0...59).
    ///   - second: Секунда (0...59).
    /// - Returns: Дата в указанном часовом поясе или `nil`, если компоненты невалидны.
    func createDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = self.timeZone
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components)
    }
}
