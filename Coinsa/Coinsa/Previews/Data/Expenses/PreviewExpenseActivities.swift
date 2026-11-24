//
//  PreviewExpenseActivities.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

// MARK: - Покупки по маршрутам

extension PreviewExpenseCatalog {
    /// Возвращает покупки с явными днями и временем, согласованными с маршрутом.
    /// - Parameter location: Локация синтетического маршрута.
    static func activities(for location: PreviewLocation) -> [PreviewExpenseActivity] {
        switch location {
        case .kotor:
            [
                PreviewExpenseActivity(.landmark, 15, 0, "Подъем к крепости Сан-Джованни", dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.souvenirs, 8.65, 0, "Открытки с видами залива", dayOffset: 0, hour: 15, minute: 0),
                PreviewExpenseActivity(.ferry, 5, 3, "Паром Каменари — Лепетане", coordinate: Coordinate(latitude: 42.4661, longitude: 18.674, horizontalAccuracy: 25), dayOffset: 1, hour: 10, minute: 45),
                PreviewExpenseActivity(.tour, 30, 4, "Прогулка на лодке из Пераста", dayOffset: 1, hour: 14, minute: 10),
                PreviewExpenseActivity(.touristTax, 4, 0, "Туристический сбор за четыре ночи", dayOffset: 0, hour: 17, minute: 15),
                PreviewExpenseActivity(.jewelry, 18.9, 3, "Серебряная подвеска на память", dayOffset: 1, hour: 18, minute: 15),
                PreviewExpenseActivity(.landmark, 4, 5, "Вход к римским мозаикам в Рисане", dayOffset: 2, hour: 10, minute: 40),
                PreviewExpenseActivity(.vehicleRental, 44.95, 3, "Аренда автомобиля для поездки вдоль залива", dayOffset: 3, hour: 9, minute: 45),
                PreviewExpenseActivity(.tips, 2, 1, "Чаевые после ужина на набережной", dayOffset: 3, hour: 20, minute: 20),
                PreviewExpenseActivity(.parking, 3, 4, "Парковка возле Пераста", dayOffset: 3, hour: 11, minute: 0),
            ]
        case .sarajevo:
            [
                PreviewExpenseActivity(.landmark, 10, 0, "Билет в музей в старом городе", dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.donation, 3, 0, "Пожертвование на содержание исторического здания", dayOffset: 0, hour: 12, minute: 10),
                PreviewExpenseActivity(.activity, 30, 1, "Канатная дорога на Требевич", coordinate: Coordinate(latitude: 43.8515, longitude: 18.4333, horizontalAccuracy: 25), dayOffset: 1, hour: 10, minute: 30),
                PreviewExpenseActivity(.souvenirs, 18.75, 0, "Медная джезва с рынка", dayOffset: 0, hour: 15, minute: 0),
                PreviewExpenseActivity(.medication, 12.4, 2, "Пластырь и средство от простуды", dayOffset: 1, hour: 18, minute: 0),
                PreviewExpenseActivity(.postalService, 5, 1, "Отправка открыток домой", dayOffset: 1, hour: 16, minute: 55),
                PreviewExpenseActivity(.park, 6, 4, "Прогулка у истоков Босны", dayOffset: 2, hour: 10, minute: 45),
                PreviewExpenseActivity(.clothing, 37.9, 2, "Худи с принтом", dayOffset: 3, hour: 11, minute: 30),
                PreviewExpenseActivity(.luggageStorage, 8, 1, "Оставил чемодан до вечернего автобуса", dayOffset: 3, hour: 9, minute: 50),
                PreviewExpenseActivity(.otherShopping, 4, 0, "Подарочная упаковка для джезвы", dayOffset: 0, hour: 15, minute: 25),
            ]
        case .belgrade:
            [
                PreviewExpenseActivity(.landmark, 800, 0, "Музей в крепости Калемегдан", coordinate: Coordinate(latitude: 44.823, longitude: 20.4508, horizontalAccuracy: 25), dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.connectivity, 1199, 0, "Местная SIM-карта с интернетом", dayOffset: 0, hour: 11, minute: 45),
                PreviewExpenseActivity(.cosmetics, 1849.9, 2, "Крем и дорожный набор", dayOffset: 1, hour: 11, minute: 0),
                PreviewExpenseActivity(.homeGoods, 2390.5, 2, "Керамические чашки из Земуна", dayOffset: 1, hour: 14, minute: 15),
                PreviewExpenseActivity(.entertainment, 1600, 1, "Вечерний концерт в небольшом зале", dayOffset: 2, hour: 21, minute: 0),
                PreviewExpenseActivity(.bankFees, 350, 0, "Комиссия за снятие наличных", dayOffset: 0, hour: 15, minute: 0),
                PreviewExpenseActivity(.digitalService, 6, 0, "Аудиогид по Белграду", currency: .eur, dayOffset: 0, hour: 9, minute: 40),
                PreviewExpenseActivity(.medicalCare, 3800, 1, "Прием в частной клинике", dayOffset: 2, hour: 10, minute: 30),
                PreviewExpenseActivity(.electronics, 3199.99, 3, "Пауэрбанк взамен сломанного", dayOffset: 3, hour: 11, minute: 15),
                PreviewExpenseActivity(.otherLeisure, 600, 4, "Прокат настольной игры в кафе", dayOffset: 4, hour: 14, minute: 15),
                PreviewExpenseActivity(.relaxation, 2800, 1, "Массаж после долгих прогулок", dayOffset: 2, hour: 17, minute: 15),
                PreviewExpenseActivity(.otherMiscellaneous, 100, 2, "Платный туалет на прогулке", dayOffset: 1, hour: 17, minute: 10),
                PreviewExpenseActivity(.laundry, 949.5, 3, "Стирка и сушка вещей", dayOffset: 3, hour: 10, minute: 0),
                PreviewExpenseActivity(.documents, 500, 0, "Копии документов для дальнейшей поездки", dayOffset: 0, hour: 17, minute: 10),
                PreviewExpenseActivity(.hygiene, 648.75, 5, "Антисептик и защитные маски", dayOffset: 4, hour: 18, minute: 15),
            ]
        case .hongKong:
            [
                PreviewExpenseActivity(.travelPass, 80, 0, "Пополнение транспортной карты", dayOffset: 0, hour: 8, minute: 55),
                PreviewExpenseActivity(.ferry, 5, 0, "Паром Star Ferry до Сентрала", coordinate: Coordinate(latitude: 22.2935, longitude: 114.169, horizontalAccuracy: 25), dayOffset: 0, hour: 10, minute: 0),
                PreviewExpenseActivity(.landmark, 90, 2, "Смотровая площадка на пике Виктория", coordinate: Coordinate(latitude: 22.271, longitude: 114.149, horizontalAccuracy: 25), dayOffset: 0, hour: 15, minute: 0),
                PreviewExpenseActivity(.electronics, 239.9, 1, "Компактное зарядное устройство", dayOffset: 1, hour: 10, minute: 30),
                PreviewExpenseActivity(.clothing, 189.5, 1, "Бейсболка", dayOffset: 1, hour: 11, minute: 10),
                PreviewExpenseActivity(.otherTransport, 35, 2, "Поездка на Peak Tram", coordinate: Coordinate(latitude: 22.2777, longitude: 114.159, horizontalAccuracy: 25), dayOffset: 0, hour: 14, minute: 15),
                PreviewExpenseActivity(.tour, 32, 5, "Билет на канатную дорогу, оплата онлайн", currency: .usd, dayOffset: 2, hour: 10, minute: 0),
                PreviewExpenseActivity(.homeGoods, 84.8, 3, "Набор палочек для дома", dayOffset: 1, hour: 16, minute: 55),
                PreviewExpenseActivity(.park, 30, 6, "Билет в Hong Kong Wetland Park", coordinate: Coordinate(latitude: 22.469, longitude: 114.004, horizontalAccuracy: 25), dayOffset: 3, hour: 10, minute: 30),
                PreviewExpenseActivity(.luggageStorage, 60, 0, "Хранение чемодана перед вылетом", dayOffset: 3, hour: 18, minute: 30),
            ]
        case .hanoi:
            [
                PreviewExpenseActivity(.tour, 350000, 0, "Пешая прогулка по старому кварталу", dayOffset: 0, hour: 10, minute: 0),
                PreviewExpenseActivity(.souvenirs, 178500, 0, "Кофе и фильтр фин в подарок", dayOffset: 0, hour: 15, minute: 10),
                PreviewExpenseActivity(.medicalCare, 450000, 2, "Консультация в клинике", dayOffset: 1, hour: 10, minute: 30),
                PreviewExpenseActivity(.hygiene, 64500, 2, "Репеллент и антисептик", dayOffset: 1, hour: 11, minute: 45),
                PreviewExpenseActivity(.documents, 20000, 1, "Печать билетов и копии паспорта", dayOffset: 2, hour: 18, minute: 0),
                PreviewExpenseActivity(.entertainment, 150000, 0, "Театр кукол на воде", dayOffset: 0, hour: 21, minute: 0),
                PreviewExpenseActivity(.landmark, 70000, 3, "Вход в Храм литературы", coordinate: Coordinate(latitude: 21.0281, longitude: 105.8355, horizontalAccuracy: 25), dayOffset: 2, hour: 10, minute: 45),
                PreviewExpenseActivity(.laundry, 90000, 0, "Стирка вещей перед следующим перелетом", dayOffset: 3, hour: 10, minute: 15),
                PreviewExpenseActivity(.accommodationServices, 100000, 0, "Доплата за поздний выезд, оплатил уже из Бангкока", coordinate: Coordinate(latitude: 13.761, longitude: 100.498, horizontalAccuracy: 25), timeZoneID: "Asia/Bangkok", dayOffset: 4, hour: 13, minute: 15),
                PreviewExpenseActivity(.digitalService, 4, 0, "Офлайн-аудиогид по Ханою", currency: .usd, dayOffset: 0, hour: 9, minute: 40),
            ]
        case .bangkok:
            [
                PreviewExpenseActivity(.landmark, 500, 0, "Билет в Большой дворец", coordinate: Coordinate(latitude: 13.75, longitude: 100.491, horizontalAccuracy: 25), dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.ferry, 30, 1, "Лодка по Чаупхрае", dayOffset: 0, hour: 17, minute: 30),
                PreviewExpenseActivity(.tour, 35, 0, "Экскурсия по храмам, предоплата онлайн", currency: .usd, dayOffset: 0, hour: 9, minute: 40),
                PreviewExpenseActivity(.clothing, 450, 4, "Легкая рубашка на рынке", dayOffset: 1, hour: 10, minute: 30),
                PreviewExpenseActivity(.cosmetics, 279.5, 4, "Солнцезащитный крем", dayOffset: 1, hour: 11, minute: 15),
                PreviewExpenseActivity(.jewelry, 350, 1, "Браслет с ночного рынка", dayOffset: 0, hour: 18, minute: 15),
                PreviewExpenseActivity(.relaxation, 400, 2, "Тайский массаж после прогулки", dayOffset: 2, hour: 17, minute: 15),
                PreviewExpenseActivity(.train, 45, 4, "Поездка по городской железной дороге", dayOffset: 1, hour: 9, minute: 45),
                PreviewExpenseActivity(.tips, 40, 1, "Чаевые после ужина в Чайнатауне", dayOffset: 0, hour: 20, minute: 20),
                PreviewExpenseActivity(.donation, 60, 0, "Пожертвование в храме", dayOffset: 0, hour: 12, minute: 10),
                PreviewExpenseActivity(.equipmentRental, 40, 4, "Прокат коврика для отдыха в парке", dayOffset: 1, hour: 15, minute: 10),
                PreviewExpenseActivity(.entertainment, 600, 2, "Вечерняя музыкальная программа", dayOffset: 2, hour: 21, minute: 0),
                PreviewExpenseActivity(.postalService, 90, 1, "Открытки родным", dayOffset: 3, hour: 11, minute: 15),
                PreviewExpenseActivity(.otherShopping, 49.75, 4, "Чехол для покупок с рынка", dayOffset: 1, hour: 14, minute: 15),
                PreviewExpenseActivity(.connectivity, 299, 5, "Дополнительный пакет мобильного интернета", dayOffset: 4, hour: 11, minute: 0),
            ]
        case .phuket:
            [
                PreviewExpenseActivity(.vehicleRental, 1200, 0, "Аренда автомобиля на один день", dayOffset: 1, hour: 10, minute: 30),
                PreviewExpenseActivity(.fuel, 647.85, 0, "Заправка перед поездкой по острову", dayOffset: 1, hour: 11, minute: 10),
                PreviewExpenseActivity(.beach, 200, 2, "Два лежака на пляже Карон", dayOffset: 2, hour: 10, minute: 15),
                PreviewExpenseActivity(.activity, 1800, 3, "Доплата за морскую прогулку и снорклинг после предоплаты", dayOffset: 3, hour: 9, minute: 50),
                PreviewExpenseActivity(.transfer, 500, 6, "Трансфер из аэропорта", dayOffset: 0, hour: 9, minute: 15),
                PreviewExpenseActivity(.medication, 179.5, 1, "Средство после солнечного ожога", dayOffset: 2, hour: 18, minute: 0),
                PreviewExpenseActivity(.tour, 45, 1, "Предоплата морской экскурсии на следующий день", currency: .usd, dayOffset: 2, hour: 20, minute: 45),
                PreviewExpenseActivity(.relaxation, 450, 1, "Массаж после пляжа", dayOffset: 0, hour: 17, minute: 15),
                PreviewExpenseActivity(.souvenirs, 318.75, 0, "Пряности и небольшие подарки", dayOffset: 1, hour: 14, minute: 15),
                PreviewExpenseActivity(.equipmentRental, 150, 2, "Прокат пляжного зонта", dayOffset: 2, hour: 10, minute: 30),
                PreviewExpenseActivity(.ferry, 400, 3, "Катер до соседнего острова", dayOffset: 3, hour: 9, minute: 35),
                PreviewExpenseActivity(.landmark, 200, 0, "Билет в музей старого города", dayOffset: 1, hour: 11, minute: 45),
                PreviewExpenseActivity(.laundry, 120, 4, "Стирка пляжных вещей", dayOffset: 1, hour: 18, minute: 0),
                PreviewExpenseActivity(.luggageStorage, 100, 5, "Хранение багажа до трансфера", dayOffset: 4, hour: 9, minute: 50),
                PreviewExpenseActivity(.otherMiscellaneous, 30, 2, "Душ после пляжа", dayOffset: 2, hour: 17, minute: 0),
            ]
        case .kualaLumpur:
            [
                PreviewExpenseActivity(.landmark, 98, 0, "Смотровая площадка башен Петронас", coordinate: Coordinate(latitude: 3.1579, longitude: 101.712, horizontalAccuracy: 25), dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.train, 15, 3, "Поезд до Бату-Кейвс", dayOffset: 1, hour: 9, minute: 50),
                PreviewExpenseActivity(.souvenirs, 41.85, 1, "Чай и открытки", dayOffset: 3, hour: 17, minute: 15),
                PreviewExpenseActivity(.clothing, 84.9, 0, "Футболка и носки", dayOffset: 0, hour: 15, minute: 0),
                PreviewExpenseActivity(.accommodationServices, 30, 0, "Доплата за поздний выезд", dayOffset: 3, hour: 9, minute: 50),
                PreviewExpenseActivity(.bankFees, 12, 0, "Комиссия банкомата", dayOffset: 0, hour: 9, minute: 45),
                PreviewExpenseActivity(.tour, 18, 4, "Небольшой гастрономический тур", currency: .usd, dayOffset: 2, hour: 10, minute: 30),
                PreviewExpenseActivity(.park, 25, 3, "Вход в парк птиц", coordinate: Coordinate(latitude: 3.1432, longitude: 101.688, horizontalAccuracy: 25), dayOffset: 3, hour: 11, minute: 0),
                PreviewExpenseActivity(.electronics, 54.95, 0, "Кабель для зарядки", dayOffset: 0, hour: 17, minute: 0),
                PreviewExpenseActivity(.postalService, 9, 1, "Последние открытки из поездки", dayOffset: 3, hour: 18, minute: 0),
            ]
        case .sergievPosad:
            [
                PreviewExpenseActivity(.train, 490, 5, "Обратный билет на электричку до Москвы", dayOffset: 0, hour: 22, minute: 5),
                PreviewExpenseActivity(.landmark, 700, 2, "Билет в музейный комплекс «Конный двор»", dayOffset: 0, hour: 10, minute: 45),
                PreviewExpenseActivity(.luggageStorage, 450, 5, "Оставил рюкзак на вокзале до вечера", dayOffset: 0, hour: 8, minute: 55),
                PreviewExpenseActivity(.snack, 249.90, 2, "Кофе после посещения Конного двора", dayOffset: 0, hour: 12, minute: 0),
                PreviewExpenseActivity(.tour, 550, 4, "Экскурсия по пещерному храму Черниговского скита", dayOffset: 0, hour: 14, minute: 45),
                PreviewExpenseActivity(.souvenirs, 349.50, 0, "Открытки с видами лавры", dayOffset: 0, hour: 20, minute: 5),
                PreviewExpenseActivity(.otherMiscellaneous, 80, 3, "Платный туалет на прогулке у Келарского пруда", dayOffset: 0, hour: 17, minute: 15),
            ]
        case .saintPetersburg:
            [
                PreviewExpenseActivity(.landmark, 700, 3, "Выставка в Русском музее", coordinate: Coordinate(latitude: 59.9387, longitude: 30.3324, horizontalAccuracy: 25), dayOffset: 0, hour: 10, minute: 30),
                PreviewExpenseActivity(.tour, 1500, 2, "Прогулка на катере по каналам", dayOffset: 0, hour: 14, minute: 30),
                PreviewExpenseActivity(.entertainment, 2800, 3, "Билет на вечерний спектакль", dayOffset: 0, hour: 21, minute: 0),
                PreviewExpenseActivity(.homeGoods, 1590.75, 0, "Керамическая тарелка из мастерской", dayOffset: 1, hour: 11, minute: 0),
                PreviewExpenseActivity(.accommodationServices, 1200, 0, "Уборка квартиры, оплатил после возвращения в Москву", coordinate: Coordinate(latitude: 55.757, longitude: 37.586, horizontalAccuracy: 40), timeZoneID: "Europe/Moscow", dayOffset: 4, hour: 12, minute: 0),
                PreviewExpenseActivity(.souvenirs, 648.9, 5, "Открытки и значок из Севкабеля", dayOffset: 1, hour: 17, minute: 0),
                PreviewExpenseActivity(.park, 1500, 4, "Нижний парк Петергофа", dayOffset: 2, hour: 12, minute: 0),
                PreviewExpenseActivity(.train, 160, 4, "Электричка до Петергофа", coordinate: Coordinate(latitude: 59.9076, longitude: 30.2998, horizontalAccuracy: 25), dayOffset: 2, hour: 10, minute: 15),
                PreviewExpenseActivity(.luggageStorage, 500, 3, "Чемодан до вечернего поезда", dayOffset: 3, hour: 17, minute: 30),
                PreviewExpenseActivity(.tips, 150, 3, "Чаевые после ужина", dayOffset: 3, hour: 20, minute: 20),
            ]
        case .noviSad, .istanbul, .saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota:
            []
        }
    }
}
