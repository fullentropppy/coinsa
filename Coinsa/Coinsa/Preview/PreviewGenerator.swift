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
            Budget(category: .food, baseAmount: 30000, location: location),
            Budget(category: .transport, baseAmount: 7200, location: location),
            Budget(category: .activity, baseAmount: 13500, location: location),
            Budget(category: .shopping, baseAmount: 10500, location: location),
            Budget(category: .medicine, baseAmount: 4200, location: location),
            Budget(category: .other, baseAmount: 6500, location: location)
        ]
    }

    private static func makeKyotoBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 15000, location: location),
            Budget(category: .activity, baseAmount: 6200, location: location)
        ]
    }

    private static func makeOsakaBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 9000, location: location)
        ]
    }

    private static func makeTokyoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 45),
                baseAmount: 980,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 13, minutes: 20),
                baseAmount: 1750,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 10, minutes: 4),
                baseAmount: 380,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 15, minutes: 58),
                baseAmount: 2100,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 20, minutes: 52),
                baseAmount: 5400,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 11, minutes: 15),
                baseAmount: 1200,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 4, hours: 14, minutes: 19),
                baseAmount: 700,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 5, hours: 19, minutes: 30),
                baseAmount: 2600,
                rateLocalToBase: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }

    private static func makeKyotoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 9, minutes: 10),
                baseAmount: 980,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.snacks.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 12, minutes: 14),
                baseAmount: 720,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 16, minutes: 48),
                baseAmount: 2100,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 19),
                baseAmount: 2600,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            )
        ]
    }

    private static func makeOsakaExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 2),
                baseAmount: 920,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 10, minutes: 27),
                baseAmount: 780,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.train.rawValue
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
                date: startDate.adding(days: 2, hours: 19),
                baseAmount: 5200,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 9, minutes: 1),
                baseAmount: 880,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.adding(days: 3, hours: 18, minutes: 50),
                baseAmount: 1900,
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
            Budget(category: .food, baseAmount: 7500, location: location),
            Budget(category: .transport, baseAmount: 1500, location: location),
            Budget(category: .activity, baseAmount: 4900, location: location),
            Budget(category: .other, baseAmount: 2000, location: location)
        ]
    }
    
    private static func makeSaintpExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 10, minutes: 19),
                baseAmount: 2150,
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
                baseAmount: 2200,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.adding(days: 21, hours: 33),
                baseAmount: 1300,
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
            Budget(category: .shopping, baseAmount: 8500, location: location)
        ]
    }

    private static func makeBusanBudgets(location: Location) -> [Budget] {
        [
            Budget(category: .food, baseAmount: 12000, location: location),
            Budget(category: .transport, baseAmount: 2800, location: location),
            Budget(category: .other, baseAmount: 2600, location: location)
        ]
    }

    private static func makeSeoulExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateLocalToBase

        return [
            Expense(
                date: startDate.adding(hours: 8, minutes: 15),
                baseAmount: 9500,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.adding(hours: 13, minutes: 31),
                baseAmount: 17000,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 9, minutes: 42),
                baseAmount: 1600,
                rateLocalToBase: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.adding(days: 1, hours: 19, minutes: 10),
                baseAmount: 22500,
                rateLocalToBase: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 11),
                baseAmount: 13000,
                rateLocalToBase: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.adding(days: 2, hours: 17, minutes: 59),
                baseAmount: 28000,
                rateLocalToBase: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: Date().startOfMinute,
                baseAmount: 6200,
                rateLocalToBase: exchangeRate,
                category: .medicine,
                location: location,
                comment: PreviewExpenseComment.pharmacy.rawValue
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
