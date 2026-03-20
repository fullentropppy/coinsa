//
//  PreviewSamples.swift
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
    case turkey
    case southKorea
    case japan
    case all
}

enum PreviewGenerator {
    // MARK: - Stored Properties

    private static let now = Date()
    private static let day: TimeInterval = 86_400
    private static let hour: TimeInterval = 3_600

    // MARK: - Public Methods

    static func makeTrips(for scenario: PreviewScenario, options: PreviewOptions) -> [Trip] {
        var trips: [Trip] = []
        
        if !options.includeTrips {
            return trips
        }

        if scenario == .all || scenario == .turkey {
            trips.append(makeTurkeyTrip(options: options))
        }
        if scenario == .all || scenario == .southKorea {
            trips.append(makeSouthKoreaTrip(options: options))
        }
        if scenario == .all || scenario == .japan {
            trips.append(makeJapanTrip(options: options))
        }
        
        return trips
    }

    // MARK: - Turkey Trip Making

    private static func makeTurkeyTrip(options: PreviewOptions) -> Trip {
        let turkeyTrip = Trip(
            name: PreviewTrip.turkey.rawValue,
            startDate: now.addingTimeInterval(-day * 97),
            endDate: now.addingTimeInterval(-day * 90)
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
            currencyCode: istanbulData.currencyCode,
            rateToBaseCurrency: istanbulData.exchangeRateToBaseCurrency,
            trip: trip
        )

        if options.includeBudgets {
            istanbul.budgets = makeIstanbulBudgets(location: istanbul)
        }

        if options.includeExpenses {
            istanbul.expenses = makeIstanbulExpenses(location: istanbul)
        }

        return istanbul
    }

    private static func makeIstanbulBudgets(location: Location) -> [Budget] {
        let exchangeRate = PreviewLocation.istanbul.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 21000, location: location),
            Budget(category: .transport, amountInBaseCurrency: exchangeRate * 3600, location: location),
            Budget(category: .activity, amountInBaseCurrency: exchangeRate * 8200, location: location),
            Budget(category: .shopping, amountInBaseCurrency: exchangeRate * 6800, location: location),
            Budget(category: .other, amountInBaseCurrency: exchangeRate * 4200, location: location)
        ]
    }

    private static func makeIstanbulExpenses(location: Location) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: now.addingTimeInterval(-day * 97 + hour * 8),
                amountInLocalCurrency: 720,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: now.addingTimeInterval(-day * 97 + hour * 19),
                amountInLocalCurrency: 2100,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: now.addingTimeInterval(-day * 96 + hour * 11),
                amountInLocalCurrency: 140,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: now.addingTimeInterval(-day * 95 + hour * 18),
                amountInLocalCurrency: 680,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            Expense(
                date: now.addingTimeInterval(-day * 94 + hour * 12),
                amountInLocalCurrency: 1450,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location
            ),
            Expense(
                date: now.addingTimeInterval(-day * 93 + hour * 20),
                amountInLocalCurrency: 980,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: now.addingTimeInterval(-day * 91 + hour * 9),
                amountInLocalCurrency: 2350,
                rateToBaseCurrency: exchangeRate,
                category: .other,
                location: location
            )
        ]
    }

    // MARK: - South Korea Trip Making

    private static func makeSouthKoreaTrip(options: PreviewOptions) -> Trip {
        let startDate = now.addingTimeInterval(-day * 3)
        let endDate = startDate.addingTimeInterval(day * 10)

        let southKoreaTrip = Trip(
            name: PreviewTrip.southKorea.rawValue,
            startDate: startDate,
            endDate: endDate
        )

        guard options.includeLocations else {
            return southKoreaTrip
        }

        let seoulEndDate = startDate.addingTimeInterval(day * 6)
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
            currencyCode: seoulData.currencyCode,
            rateToBaseCurrency: seoulData.exchangeRateToBaseCurrency,
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
            currencyCode: busanData.currencyCode,
            rateToBaseCurrency: busanData.exchangeRateToBaseCurrency,
            trip: trip
        )

        if options.includeBudgets {
            busan.budgets = makeBusanBudgets(location: busan)
        }

        if options.includeExpenses {
            busan.expenses = makeBusanExpenses(location: busan, startDate: startDate)
        }

        return busan
    }

    private static func makeSeoulBudgets(location: Location) -> [Budget] {
        let exchangeRate = PreviewLocation.seoul.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 24000, location: location),
            Budget(category: .transport, amountInBaseCurrency: exchangeRate * 5200, location: location),
            Budget(category: .activity, amountInBaseCurrency: exchangeRate * 11000, location: location),
            Budget(category: .shopping, amountInBaseCurrency: exchangeRate * 8500, location: location)
        ]
    }

    private static func makeBusanBudgets(location: Location) -> [Budget] {
        let exchangeRate = PreviewLocation.busan.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 12000, location: location),
            Budget(category: .transport, amountInBaseCurrency: exchangeRate * 2800, location: location),
            Budget(category: .other, amountInBaseCurrency: exchangeRate * 2600, location: location)
        ]
    }

    private static func makeSeoulExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: startDate.addingTimeInterval(hour * 8),
                amountInLocalCurrency: 9500,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(hour * 13),
                amountInLocalCurrency: 17000,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 9),
                amountInLocalCurrency: 1600,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 19),
                amountInLocalCurrency: 22500,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 11),
                amountInLocalCurrency: 13000,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 17),
                amountInLocalCurrency: 28000,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 14),
                amountInLocalCurrency: 6200,
                rateToBaseCurrency: exchangeRate,
                category: .medicine,
                location: location,
                comment: PreviewExpenseComment.pharmacy.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 20),
                amountInLocalCurrency: 52000,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 4 + hour * 12),
                amountInLocalCurrency: 3100,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 5 + hour * 18),
                amountInLocalCurrency: 8900,
                rateToBaseCurrency: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }

    private static func makeBusanExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: startDate.addingTimeInterval(hour * 10),
                amountInLocalCurrency: 12500,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 9),
                amountInLocalCurrency: 1800,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 15),
                amountInLocalCurrency: 29500,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.temple.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 20),
                amountInLocalCurrency: 14000,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 12),
                amountInLocalCurrency: 5200,
                rateToBaseCurrency: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }

    // MARK: - Japan Trip Making

    private static func makeJapanTrip(options: PreviewOptions) -> Trip {
        let startDate = now.addingTimeInterval(day * 20)
        let endDate = startDate.addingTimeInterval(day * 14)

        let japanTrip = Trip(
            name: PreviewTrip.japan.rawValue,
            startDate: startDate,
            endDate: endDate
        )

        guard options.includeLocations else {
            return japanTrip
        }

        let tokyoEndDate = startDate.addingTimeInterval(day * 6)
        let kyotoEndDate = tokyoEndDate.addingTimeInterval(day * 4)

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
            currencyCode: tokyoData.currencyCode,
            rateToBaseCurrency: tokyoData.exchangeRateToBaseCurrency,
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
            currencyCode: kyotoData.currencyCode,
            rateToBaseCurrency: kyotoData.exchangeRateToBaseCurrency,
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
            currencyCode: osakaData.currencyCode,
            rateToBaseCurrency: osakaData.exchangeRateToBaseCurrency,
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
        let exchangeRate = PreviewLocation.tokyo.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 30000, location: location),
            Budget(category: .transport, amountInBaseCurrency: exchangeRate * 7200, location: location),
            Budget(category: .activity, amountInBaseCurrency: exchangeRate * 13500, location: location),
            Budget(category: .shopping, amountInBaseCurrency: exchangeRate * 10500, location: location),
            Budget(category: .medicine, amountInBaseCurrency: exchangeRate * 4200, location: location),
            Budget(category: .other, amountInBaseCurrency: exchangeRate * 6500, location: location)
        ]
    }

    private static func makeKyotoBudgets(location: Location) -> [Budget] {
        let exchangeRate = PreviewLocation.kyoto.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 15000, location: location),
            Budget(category: .activity, amountInBaseCurrency: exchangeRate * 6200, location: location)
        ]
    }

    private static func makeOsakaBudgets(location: Location) -> [Budget] {
        let exchangeRate = PreviewLocation.osaka.exchangeRateFromBaseCurrency

        return [
            Budget(category: .food, amountInBaseCurrency: exchangeRate * 9000, location: location)
        ]
    }

    private static func makeTokyoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: startDate.addingTimeInterval(hour * 8),
                amountInLocalCurrency: 980,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(hour * 13),
                amountInLocalCurrency: 1750,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 10),
                amountInLocalCurrency: 380,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 15),
                amountInLocalCurrency: 2100,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 20),
                amountInLocalCurrency: 5400,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 11),
                amountInLocalCurrency: 1200,
                rateToBaseCurrency: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 4 + hour * 14),
                amountInLocalCurrency: 700,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 5 + hour * 19),
                amountInLocalCurrency: 2600,
                rateToBaseCurrency: exchangeRate,
                category: .other,
                location: location,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }

    private static func makeKyotoExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: startDate.addingTimeInterval(hour * 9),
                amountInLocalCurrency: 980,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location,
                comment: PreviewExpenseComment.snacks.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 12),
                amountInLocalCurrency: 720,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 16),
                amountInLocalCurrency: 2100,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 19),
                amountInLocalCurrency: 2600,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.souvenirs.rawValue
            )
        ]
    }

    private static func makeOsakaExpenses(location: Location, startDate: Date) -> [Expense] {
        let exchangeRate = location.rateToBaseCurrency

        return [
            Expense(
                date: startDate.addingTimeInterval(hour * 8),
                amountInLocalCurrency: 920,
                rateToBaseCurrency: exchangeRate,
                category: .food,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 1 + hour * 10),
                amountInLocalCurrency: 780,
                rateToBaseCurrency: exchangeRate,
                category: .transport,
                location: location,
                comment: PreviewExpenseComment.train.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 13),
                amountInLocalCurrency: 2400,
                rateToBaseCurrency: exchangeRate,
                category: .activity,
                location: location,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 2 + hour * 19),
                amountInLocalCurrency: 5200,
                rateToBaseCurrency: exchangeRate,
                category: .shopping,
                location: location,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 9),
                amountInLocalCurrency: 880,
                rateToBaseCurrency: exchangeRate,
                category: .medicine,
                location: location
            ),
            Expense(
                date: startDate.addingTimeInterval(day * 3 + hour * 18),
                amountInLocalCurrency: 1900,
                rateToBaseCurrency: exchangeRate,
                category: .other,
                location: location
            )
        ]
    }
}
