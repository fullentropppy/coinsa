//
//  PreviewExpenseCatalog.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Именованное место синтетической покупки с приблизительными координатами.
struct PreviewExpensePlace {
    // MARK: - Свойства

    let name: String
    let latitude: Double
    let longitude: Double

    // MARK: - Инициализация

    /// Создает место в конкретном районе или у достопримечательности.
    /// - Parameters:
    ///   - name: Название места для осмысленного комментария.
    ///   - latitude: Приблизительная географическая широта.
    ///   - longitude: Приблизительная географическая долгота.
    init(_ name: String, _ latitude: Double, _ longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Дополнительная покупка на маршруте, дополняющая повседневные траты.
struct PreviewExpenseActivity {
    // MARK: - Свойства

    let subcategory: ExpenseSubcategory
    let amount: Double
    let placeIndex: Int
    let comment: String
    let currency: Currency?
    let coordinate: Coordinate?
    let dayOffset: Int
    let minuteOfDay: Int
    let timeZoneID: String?

    // MARK: - Инициализация

    /// Создает конкретную покупку с суммой в указанной или местной валюте.
    /// - Parameters:
    ///   - subcategory: Подкатегория покупки.
    ///   - amount: Исходная сумма до конвертации.
    ///   - placeIndex: Индекс района в маршруте локации.
    ///   - comment: Описание покупки.
    ///   - currency: Валюта оплаты; `nil` означает валюту локации.
    ///   - coordinate: Координаты конкретного объекта вместо центра района.
    ///   - timeZoneID: Пояс места фактической оплаты вместо пояса локации.
    ///   - dayOffset: День оплаты относительно начала локации, в том числе после выезда.
    ///   - hour: Час оплаты по местному гражданскому времени.
    ///   - minute: Минута оплаты; время согласовано с остальными остановками дня.
    init(
        _ subcategory: ExpenseSubcategory,
        _ amount: Double,
        _ placeIndex: Int,
        _ comment: String,
        currency: Currency? = nil,
        coordinate: Coordinate? = nil,
        timeZoneID: String? = nil,
        dayOffset: Int,
        hour: Int,
        minute: Int = 0
    ) {
        self.subcategory = subcategory
        self.amount = amount
        self.placeIndex = placeIndex
        self.comment = comment
        self.currency = currency
        self.coordinate = coordinate
        self.dayOffset = dayOffset
        self.minuteOfDay = hour * 60 + minute
        self.timeZoneID = timeZoneID
    }
}

/// География и условные цены повседневных покупок без сетевых зависимостей.
enum PreviewExpenseCatalog {
    // MARK: - Методы

    /// Возвращает районы и места, разнесенные по городу и ближайшим окрестностям.
    /// - Parameter location: Локация синтетического маршрута.
    static func places(for location: PreviewLocation) -> [PreviewExpensePlace] {
        switch location {
        case .kotor:
            [
                PreviewExpensePlace("Старый город Котора", 42.4247, 18.7712),
                PreviewExpensePlace("Набережная Доброты", 42.4496, 18.765),
                PreviewExpensePlace("Прчань", 42.4557, 18.7441),
                PreviewExpensePlace("Тиват, набережная", 42.4318, 18.6961),
                PreviewExpensePlace("Пераст", 42.4863, 18.6991),
                PreviewExpensePlace("Рисан", 42.515, 18.6956),
            ]
        case .sarajevo:
            [
                PreviewExpensePlace("Башчаршия", 43.8591, 18.4312),
                PreviewExpensePlace("Марьин-Двор", 43.8557, 18.4037),
                PreviewExpensePlace("Грбавица", 43.8487, 18.39),
                PreviewExpensePlace("Илиджа", 43.83, 18.309),
                PreviewExpensePlace("Врело-Босне", 43.8196, 18.2697),
                PreviewExpensePlace("Скендерия", 43.8527, 18.4134),
            ]
        case .belgrade:
            [
                PreviewExpensePlace("Дорчол", 44.8251, 20.4633),
                PreviewExpensePlace("Врачар", 44.7981, 20.4716),
                PreviewExpensePlace("Земун, набережная", 44.8452, 20.4145),
                PreviewExpensePlace("Новый Белград, блок 45", 44.8004, 20.381),
                PreviewExpensePlace("Ада-Циганлия", 44.7881, 20.4146),
                PreviewExpensePlace("Звездара", 44.7973, 20.5001),
            ]
        case .hongKong:
            [
                PreviewExpensePlace("Цим-Ша-Цуй", 22.2987, 114.1722),
                PreviewExpensePlace("Монгкок", 22.3193, 114.1694),
                PreviewExpensePlace("Сентрал", 22.282, 114.158),
                PreviewExpensePlace("Козуэй-Бей", 22.279, 114.184),
                PreviewExpensePlace("Стэнли", 22.219, 114.2125),
                PreviewExpensePlace("Тунг-Чунг", 22.289, 113.941),
                PreviewExpensePlace("Hong Kong Wetland Park", 22.469, 114.004),
            ]
        case .hanoi:
            [
                PreviewExpensePlace("Старый квартал Ханоя", 21.0358, 105.8508),
                PreviewExpensePlace("Французский квартал", 21.018, 105.857),
                PreviewExpensePlace("Тэйхо", 21.0704, 105.8189),
                PreviewExpensePlace("Ба-Динь", 21.0373, 105.8192),
                PreviewExpensePlace("Кау-Зяй", 21.035, 105.79),
                PreviewExpensePlace("Лонгбьен", 21.045, 105.879),
            ]
        case .bangkok:
            [
                PreviewExpensePlace("Банглампху", 13.761, 100.498),
                PreviewExpensePlace("Чайнатаун", 13.7395, 100.5092),
                PreviewExpensePlace("Силом", 13.7257, 100.529),
                PreviewExpensePlace("Ари", 13.7797, 100.5446),
                PreviewExpensePlace("Чатучак", 13.7996, 100.5502),
                PreviewExpensePlace("Тхонгло", 13.729, 100.581),
            ]
        case .phuket:
            [
                PreviewExpensePlace("Старый город Пхукета", 7.883, 98.388),
                PreviewExpensePlace("Ката", 7.819, 98.299),
                PreviewExpensePlace("Карон", 7.846, 98.294),
                PreviewExpensePlace("Раваи", 7.776, 98.324),
                PreviewExpensePlace("Патонг", 7.896, 98.298),
                PreviewExpensePlace("Най-Янг", 8.091, 98.299),
                PreviewExpensePlace("Аэропорт Пхукета", 8.111, 98.306),
            ]
        case .kualaLumpur:
            [
                PreviewExpensePlace("Букит-Бинтанг", 3.1478, 101.7117),
                PreviewExpensePlace("Чайнатаун Куала-Лумпура", 3.1445, 101.697),
                PreviewExpensePlace("Кампунг-Бару", 3.1635, 101.706),
                PreviewExpensePlace("Брикфилдс", 3.1328, 101.686),
                PreviewExpensePlace("Бангсар", 3.129, 101.671),
                PreviewExpensePlace("Бату-Кейвс", 3.2379, 101.684),
            ]
        case .sergievPosad:
            [
                PreviewExpensePlace("Троице-Сергиева лавра", 56.3100, 38.1306),
                PreviewExpensePlace("Музей игрушки", 56.3051, 38.1298),
                PreviewExpensePlace("Музейный комплекс «Конный двор»", 56.3157, 38.1344),
                PreviewExpensePlace("Келарский пруд", 56.3075, 38.1235),
                PreviewExpensePlace("Черниговский скит", 56.3066, 38.1854),
                PreviewExpensePlace("Вокзал Сергиева Посада", 56.3015, 38.1358),
            ]
        case .saintPetersburg:
            [
                PreviewExpensePlace("Васильевский остров", 59.941, 30.278),
                PreviewExpensePlace("Петроградская сторона", 59.966, 30.311),
                PreviewExpensePlace("Новая Голландия", 59.929, 30.291),
                PreviewExpensePlace("Невский проспект", 59.932, 30.348),
                PreviewExpensePlace("Петергоф", 59.883, 29.907),
                PreviewExpensePlace("Севкабель Порт", 59.924, 30.241),
            ]
        case .noviSad, .istanbul, .saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota:
            []
        }
    }

    /// Возвращает последовательность районов для шести повседневных покупок каждого дня.
    /// - Parameter location: Локация синтетического маршрута.
    static func dailyRoutes(for location: PreviewLocation) -> [[Int]] {
        switch location {
        case .kotor: [[0, 0, 0, 0, 0, 0], [3, 3, 4, 4, 3, 3], [4, 4, 5, 5, 1, 1], [3, 3, 4, 1, 1, 1]]
        case .sarajevo: [[0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 2, 2], [3, 3, 4, 4, 3, 3], [1, 1, 2, 2, 1, 1]]
        case .belgrade: [[0, 0, 0, 0, 0, 0], [2, 2, 2, 2, 2, 2], [1, 1, 1, 1, 1, 1], [3, 3, 3, 3, 3, 3], [4, 4, 4, 4, 5, 5], [5, 5, 5, 5, 5, 5], [0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1]]
        case .hongKong: [[0, 0, 2, 2, 3, 3], [1, 1, 1, 3, 3, 3], [5, 5, 5, 5, 5, 5], [6, 6, 6, 6, 0, 0]]
        case .hanoi: [[0, 0, 0, 0, 0, 0], [2, 2, 2, 2, 2, 2], [3, 3, 3, 3, 1, 1], [0, 0, 0, 0, 0, 0]]
        case .bangkok: [[0, 0, 0, 0, 1, 1], [4, 4, 4, 4, 3, 3], [2, 2, 2, 2, 2, 2], [1, 1, 1, 1, 1, 1], [5, 5, 5, 5, 5, 5]]
        case .phuket: [[6, 6, 1, 1, 1, 1], [1, 1, 0, 0, 4, 4], [2, 2, 2, 2, 1, 1], [3, 3, 3, 3, 3, 3], [5, 5, 5, 5, 5, 5]]
        case .kualaLumpur: [[0, 0, 0, 0, 0, 0], [3, 3, 5, 5, 3, 3], [4, 4, 4, 4, 4, 4], [0, 0, 3, 3, 1, 1]]
        case .sergievPosad: [[5, 5, 0, 4, 0, 5]]
        case .saintPetersburg: [[3, 3, 3, 2, 3, 3], [0, 0, 0, 5, 5, 5], [3, 3, 4, 4, 3, 3], [1, 1, 1, 1, 3, 3]]
        case .noviSad, .istanbul, .saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota:
            []
        }
    }

    /// Возвращает местные цены еды, транспорта и ночи проживания.
    /// - Parameter location: Локация синтетического маршрута.
    static func prices(for location: PreviewLocation) -> [Double] {
        switch location {
        case .kotor: [7, 2, 14, 3.5, 22, 5, 60]
        case .sarajevo: [7, 1.8, 16, 4, 25, 8, 75]
        case .belgrade: [650, 750, 1300, 350, 2200, 500, 5400]
        case .hongKong: [48, 12, 85, 28, 140, 42, 520]
        case .hanoi: [55000, 10000, 90000, 35000, 150000, 40000, 600000]
        case .bangkok: [120, 45, 180, 60, 320, 90, 1100]
        case .phuket: [140, 60, 220, 80, 420, 110, 1600]
        case .kualaLumpur: [14, 3, 22, 8, 38, 12, 190]
        case .sergievPosad: [650, 70, 1100, 300, 1600, 450, 0]
        case .saintPetersburg: [550, 70, 950, 280, 1400, 400, 4500]
        case .noviSad, .istanbul, .saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota:
            []
        }
    }
}
