//
//  ViewLayout.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Повторяющиеся размеры интерфейса, сгруппированные по назначению.
enum ViewLayout {
    // MARK: - Вложенные типы

    enum Row {
        /// Интервал между основным и дополнительным содержимым строки списка.
        static let contentSpacing: CGFloat = 10
        /// Интервал между датой, счетчиком и другими краткими сведениями в строке.
        static let metadataSpacing: CGFloat = 4
        /// Ширина колонки иконок в строках аналитики.
        static let iconWidth: CGFloat = 20
    }

    enum Summary {
        /// Интервал между блоками сводки, шапки или подробностей события.
        static let sectionSpacing: CGFloat = 14
        /// Интервал между соседними карточками сумм, включая ряды карточек.
        static let cardSpacing: CGFloat = 8
    }

    enum AnalyticsExpenseChart {
        /// Высота дневного и почасового графиков трат.
        static let height: CGFloat = 200
        /// Запас сверху и снизу области графика для линии трат.
        static let plotVerticalInset: CGFloat = 2
        /// Вертикальные отступы секции графика трат.
        static let sectionVerticalInset: CGFloat = 12
    }

    enum AnalyticsDonutChart {
        /// Радиус внутреннего отверстия кольцевых диаграмм аналитики.
        static let innerRadius: CGFloat = 68
        /// Зазор между секторами кольцевых диаграмм аналитики.
        static let angularInset: CGFloat = 1
        /// Радиус скругления секторов кольцевых диаграмм аналитики.
        static let sectorCornerRadius: CGFloat = 6
        /// Высота кольцевых диаграмм аналитики.
        static let height: CGFloat = 220
    }

    enum Label {
        /// Минимальный масштаб сокращенной суммы при нехватке ширины строки.
        static let minimumAmountScaleFactor: CGFloat = 0.75
        /// Интервал между иконкой и текстом метки.
        static let iconSpacing: CGFloat = 4
        /// Интервал между компактной иконкой счетчика или действия и текстом.
        static let compactIconSpacing: CGFloat = 2
        /// Ширина колонки иконок категорий, подкатегорий, способов оплаты и др. в формах.
        static let formIconWidth: CGFloat = 24
        /// Ширина служебных элементов рядом с полем ввода: процента, переключателя и обновления.
        static let inputAccessoryWidth: CGFloat = 16
        /// Интервал между текущим значением пикера и стрелкой перехода.
        static let pickerIndicatorSpacing: CGFloat = 8
    }

    enum Card {
        /// Внутренний отступ стеклянных карточек сумм.
        static let contentInset: CGFloat = 10
        /// Радиус скругления стеклянных карточек сумм.
        static let cornerRadius: CGFloat = 12
    }

    enum FloatingControls {
        /// Отступ плавающих кнопок и панелей от бокового и нижнего края.
        static let edgeInset: CGFloat = 16
        /// Внутренний отступ основной кнопки добавления и кнопок панели клавиатуры.
        static let buttonInset: CGFloat = 16
    }

    enum Editor {
        /// Пауза после снятия фокуса перед существующим действием сохранения формы.
        static let saveAfterKeyboardDismissDelay: TimeInterval = 0.1
    }

    enum Loading {
        /// Непрозрачность содержимого на время загрузки.
        static let contentOpacity: Double = 0.46
    }

    enum Comment {
        /// Поправка сверху для выравнивания иконки с первой строкой комментария.
        static let iconTopInset: CGFloat = 3
        /// Диапазон числа видимых строк поля комментария до начала прокрутки.
        static let visibleLines = 1...10
    }
}
