//
//  PreviewGenerator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

struct PreviewOptions {
    var includeTrips = true
    var includeLocations = true
    var includeBudgets = true
    var includeExpenses = true
}

enum PreviewScenario: CaseIterable {
    case japan
    case russia
    case southKorea
    case turkey
    case all
}

enum PreviewGenerator {
    // MARK: - Stored Properties

    private static let now = Date().startOfDay

    // MARK: - Public Methods

    static func makeTrips(for scenario: PreviewScenario, options: PreviewOptions) -> [Trip] {
        var trips: [Trip] = []
        
        if !options.includeTrips {
            return trips
        }
        if scenario == .all || scenario == .japan {
            trips.append(makeJapanTrip(options: options))
        }
        if scenario == .all || scenario == .russia {
            trips.append(makeRussiaTrip(options: options))
        }
        if scenario == .all || scenario == .southKorea {
            trips.append(makeSouthKoreaTrip(options: options))
        }
        if scenario == .all || scenario == .turkey {
            trips.append(makeTurkeyTrip(options: options))
        }
        
        return trips
    }

    // MARK: - Japan Trip Making

    private static func makeJapanTrip(options: PreviewOptions) -> Trip {
        let startDate = now.adding(months: -14)
        let endDate = startDate.adding(days: 14)

        let japanTrip = Trip(
            name: PreviewTrip.japan.rawValue,
            startDate: startDate,
            endDate: endDate
        )

        guard options.includeLocations else {
            return japanTrip
        }

        let tokyoEndDate = startDate.adding(days: 6)
        let kyotoEndDate = tokyoEndDate.adding(days: 4)

        let tokyo = makeTokyoLocation(trip: japanTrip, startDate: startDate, endDate: tokyoEndDate, options: options)
        let kyoto = makeKyotoLocation(trip: japanTrip, startDate: tokyoEndDate, endDate: kyotoEndDate, options: options)
        let osaka = makeOsakaLocation(trip: japanTrip, startDate: kyotoEndDate, endDate: endDate, options: options)

        japanTrip.locations = [tokyo, kyoto, osaka]

        return japanTrip
    }

    private static func makeTokyoLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let tokyoData = PreviewLocation.tokyo

        let tokyo = Location(
            name: tokyoData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: tokyoData.currencyCode,
            rateLocalToBase: tokyoData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            tokyo.budgets = makeTokyoBudgets(location: tokyo)
        }
        if options.includeExpenses {
            tokyo.expenses = makeTokyoExpenses(location: tokyo, startDate: startDate)
        }

        return tokyo
    }

    private static func makeKyotoLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let kyotoData = PreviewLocation.kyoto

        let kyoto = Location(
            name: kyotoData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: kyotoData.currencyCode,
            rateLocalToBase: kyotoData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            kyoto.budgets = makeKyotoBudgets(location: kyoto)
        }
        if options.includeExpenses {
            kyoto.expenses = makeKyotoExpenses(location: kyoto, startDate: startDate)
        }

        return kyoto
    }

    private static func makeOsakaLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let osakaData = PreviewLocation.osaka

        let osaka = Location(
            name: osakaData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: osakaData.currencyCode,
            rateLocalToBase: osakaData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            osaka.budgets = makeOsakaBudgets(location: osaka)
        }
        if options.includeExpenses {
            osaka.expenses = makeOsakaExpenses(location: osaka, startDate: startDate)
        }

        return osaka
    }

    private static func makeTokyoBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 22000, location: location),
            Budget(category: .transport, baseAmount: 7200, location: location),
            Budget(category: .activity, baseAmount: 12550, location: location),
            Budget(category: .shopping, baseAmount: 29500, location: location),
            Budget(category: .medicine, baseAmount: 2000, location: location),
            Budget(category: .other, baseAmount: 9490, location: location)
        ]
    }

    private static func makeKyotoBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 18000, location: location),
            Budget(category: .activity, baseAmount: 5000, location: location),
            Budget(category: .shopping, baseAmount: 19000, location: location),
            Budget(category: .other, baseAmount: 20500, location: location)
        ]
    }

    private static func makeOsakaBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 14000, location: location),
            Budget(category: .transport, baseAmount: 6500, location: location),
            Budget(category: .other, baseAmount: 30000, location: location)
        ]
    }

    private static func makeTokyoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 45),
                baseAmount: 2391.90,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 13, minutes: 20),
                baseAmount: 2116.4,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 13, minutes: 58),
                baseAmount: 120.52,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 17, minutes: 11),
                baseAmount: 6219,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 23, minutes: 31),
                baseAmount: 1992,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 10, minutes: 4),
                baseAmount: 140.28,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 12, minutes: 12),
                baseAmount: 2120,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                baseAmount: 8902,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                baseAmount: 8902,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 23),
                baseAmount: 1220,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location,
                comment: PreviewExpenseComment.pharmacy.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 8, minutes: 24),
                baseAmount: 240,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 12, minutes: 01),
                baseAmount: 3098.4,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 15, minutes: 58),
                baseAmount: 3409.72,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 17),
                baseAmount: 312,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 20, minutes: 52),
                baseAmount: 12091.07,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 11, minutes: 15),
                baseAmount: 887.01,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 12, minutes: 53),
                baseAmount: 2590,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 14, minutes: 11),
                baseAmount: 1450,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 16, minutes: 40),
                baseAmount: 90.64,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 19, minutes: 28),
                baseAmount: 2500,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 23, minutes: 5),
                baseAmount: 1841.98,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 10, minutes: 15),
                baseAmount: 1882,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 14, minutes: 19),
                baseAmount: 504.07,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 14, minutes: 59),
                baseAmount: 1003.6,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 17, minutes: 30),
                baseAmount: 5902,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 5, hours: 19, minutes: 30),
                baseAmount: 2600,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 20, minutes: 50),
                baseAmount: 202,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 23, minutes: 42),
                baseAmount: 3850.2,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
        ]
    }

    private static func makeKyotoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 14),
                baseAmount: 6250,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.train.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 9),
                baseAmount: 1200,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.snacks.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 10, minutes: 19),
                baseAmount: 3509.9,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 10, minutes: 54),
                baseAmount: 2500.05,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 13, minutes: 14),
                baseAmount: 5209.6,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 14, minutes: 20),
                baseAmount: 120,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 14, minutes: 57),
                baseAmount: 2691,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 16, minutes: 50),
                baseAmount: 890,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.temple.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 19, minutes: 10),
                baseAmount: 212,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 20, minutes: 19),
                baseAmount: 1620.18,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 9, minutes: 36),
                baseAmount: 2906.7,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 10, minutes: 53),
                baseAmount: 1105,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 14, minutes: 32),
                baseAmount: 2000.05,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 16, minutes: 50),
                baseAmount: 2012,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 20, minutes: 15),
                baseAmount: 29020,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 22, minutes: 28),
                baseAmount: 3040.84,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 9),
                baseAmount: 706,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 10, minutes: 12),
                baseAmount: 706,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.train.rawValue
            )
        ]
    }

    private static func makeOsakaExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 11, minutes: 49),
                baseAmount: 2099,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 15, minutes: 20),
                baseAmount: 201,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 16, minutes: 16),
                baseAmount: 2720.91,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 17, minutes: 39),
                baseAmount: 290,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 21, minutes: 15),
                baseAmount: 290,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 10, minutes: 27),
                baseAmount: 1556,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 14, minutes: 1),
                baseAmount: 6991.44,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 14, minutes: 32),
                baseAmount: 4010,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 18, minutes: 49),
                baseAmount: 1900.04,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 20, minutes: 59),
                baseAmount: 1498.89,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 10, minutes: 15),
                baseAmount: 2068,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 13, minutes: 13),
                baseAmount: 2400,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 14, minutes: 20),
                baseAmount: 309.06,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 19),
                baseAmount: 5200,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 22),
                baseAmount: 2095,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 5, minutes: 1),
                baseAmount: 5252.9,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 7, minutes: 26),
                baseAmount: 4520,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 8, minutes: 44),
                baseAmount: 6270,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            )
        ]
    }
    
    // MARK: - Russia Trip Making
    
    private static func makeRussiaTrip(options: PreviewOptions) -> Trip {
        let startDate = now.adding(months: -2)
        let endDate = startDate
        
        let russiaTrip = Trip(
            name: PreviewTrip.russia.rawValue,
            startDate: startDate,
            endDate: endDate
        )
        
        guard options.includeLocations else {
            return russiaTrip
        }
        
        let saintp = makeSaintpLocation(trip: russiaTrip, startDate: startDate, endDate: endDate, options: options)
        
        russiaTrip.locations = [saintp]
        
        return russiaTrip
    }
    
    private static func makeSaintpLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let saintpData = PreviewLocation.saintp

        let saintp = Location(
            name: saintpData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: saintpData.currencyCode,
            rateLocalToBase: saintpData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            saintp.budgets = makeSaintpBudgets(location: saintp)
        }
        if options.includeExpenses {
            saintp.expenses = makeSaintpExpenses(location: saintp, startDate: startDate)
        }
        
        return saintp
    }
    
    private static func makeSaintpBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 7000, location: location),
            Budget(category: .transport, baseAmount: 1500, location: location),
            Budget(category: .activity, baseAmount: 4500, location: location),
            Budget(category: .other, baseAmount: 2000, location: location)
        ]
    }
    
    private static func makeSaintpExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 10, minutes: 19),
                baseAmount: 2990,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
            ),
            Expense(
                date: startDate.adding(hours: 13),
                baseAmount: 950,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 16, minutes: 17),
                baseAmount: 2400,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 21, minutes: 33),
                baseAmount: 1800,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
            )
        ]
    }
    
    // MARK: - South Korea Trip Making

    private static func makeSouthKoreaTrip(options: PreviewOptions) -> Trip {
        let startDate = now.adding(days: -3)
        let endDate = startDate.adding(days: 10)

        let southKoreaTrip = Trip(
            name: PreviewTrip.southKorea.rawValue,
            startDate: startDate,
            endDate: endDate
        )

        guard options.includeLocations else {
            return southKoreaTrip
        }

        let seoulEndDate = startDate.adding(days: 6)
        let seoul = makeSeoulLocation(trip: southKoreaTrip, startDate: startDate, endDate: seoulEndDate, options: options)
        let busan = makeBusanLocation(trip: southKoreaTrip, startDate: seoulEndDate, endDate: endDate, options: options)

        southKoreaTrip.locations = [seoul, busan]

        return southKoreaTrip
    }

    private static func makeSeoulLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let seoulData = PreviewLocation.seoul

        let seoul = Location(
            name: seoulData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: seoulData.currencyCode,
            rateLocalToBase: seoulData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            seoul.budgets = makeSeoulBudgets(location: seoul)
        }

        if options.includeExpenses {
            seoul.expenses = makeSeoulExpenses(location: seoul, startDate: startDate)
        }

        return seoul
    }

    private static func makeBusanLocation(
        trip: Trip,
        startDate: Date,
        endDate: Date,
        options: PreviewOptions
    ) -> Location {
        let busanData = PreviewLocation.busan

        let busan = Location(
            name: busanData.rawValue,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: busanData.currencyCode,
            rateLocalToBase: busanData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            busan.budgets = makeBusanBudgets(location: busan)
        }

        return busan
    }

    private static func makeSeoulBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 24000, location: location),
            Budget(category: .transport, baseAmount: 5200, location: location),
            Budget(category: .activity, baseAmount: 11000, location: location),
            Budget(category: .shopping, baseAmount: 20000, location: location)
        ]
    }

    private static func makeBusanBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 12000, location: location),
            Budget(category: .transport, baseAmount: 2800, location: location),
            Budget(category: .other, baseAmount: 15000, location: location)
        ]
    }

    private static func makeSeoulExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 15),
                baseAmount: 3205.92,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 9, minutes: 14),
                baseAmount: 312,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 14, minutes: 12),
                baseAmount: 2301,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 15, minutes: 53),
                baseAmount: 150,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 16, minutes: 14),
                baseAmount: 924.13,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 19, minutes: 49),
                baseAmount: 9200.2,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location
            ),
            Expense(
                date: startDate.adding(hours: 21, minutes: 10),
                baseAmount: 2909,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 9, minutes: 11),
                baseAmount: 2450,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 10, minutes: 15),
                baseAmount: 292.4,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 13, minutes: 13),
                baseAmount: 1043,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 15, minutes: 16),
                baseAmount: 1687,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 16, minutes: 37),
                baseAmount: 300,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 19, minutes: 50),
                baseAmount: 2540.14,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 11),
                baseAmount: 2051.51,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 12, minutes: 7),
                baseAmount: 199.3,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 17, minutes: 59),
                baseAmount: 14200,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 19, minutes: 40),
                baseAmount: 1250,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 22, minutes: 1),
                baseAmount: 1940.2,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 23, minutes: 44),
                baseAmount: 1001,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: Date().startOfMinute,
                baseAmount: 2046,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            )
        ]
    }
    
    // MARK: - Turkey Trip Making

    private static func makeTurkeyTrip(options: PreviewOptions) -> Trip {
        let startDate = now.adding(months: 3)
        let endDate = startDate.adding(days: 7)
        
        let turkeyTrip = Trip(
            name: PreviewTrip.turkey.rawValue,
            startDate: startDate,
            endDate: endDate
        )

        guard options.includeLocations else {
            return turkeyTrip
        }

        let istanbul = makeIstanbulLocation(trip: turkeyTrip, options: options)
        turkeyTrip.locations = [istanbul]

        return turkeyTrip
    }

    private static func makeIstanbulLocation(trip: Trip, options: PreviewOptions) -> Location {
        let istanbulData = PreviewLocation.istanbul

        let istanbul = Location(
            name: istanbulData.rawValue,
            startDate: trip.startDate,
            endDate: trip.endDate,
            localCurrencyCode: istanbulData.currencyCode,
            rateLocalToBase: istanbulData.exchangeRate,
            trip: trip
        )

        if options.includeBudgets {
            istanbul.budgets = makeIstanbulBudgets(location: istanbul)
        }

        return istanbul
    }

    private static func makeIstanbulBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 21000, location: location),
            Budget(category: .transport, baseAmount: 3600, location: location),
            Budget(category: .activity, baseAmount: 8200, location: location),
            Budget(category: .shopping, baseAmount: 6800, location: location),
            Budget(category: .other, baseAmount: 4200, location: location)
        ]
    }
}
