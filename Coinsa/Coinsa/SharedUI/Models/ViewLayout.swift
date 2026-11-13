//
//  ViewLayout.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Повторяющиеся размеры интерфейса, сгруппированные по назначению.
enum ViewLayout {
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

    enum Label {
        /// Интервал между иконкой и текстом метки.
        static let iconSpacing: CGFloat = 4
        /// Интервал между компактной иконкой счетчика или действия и текстом.
        static let compactIconSpacing: CGFloat = 2
        /// Ширина колонки иконок категорий, подкатегорий и способов оплаты в формах.
        static let formIconWidth: CGFloat = 28
        /// Ширина служебных элементов рядом с полем ввода: процента, переключателя и обновления.
        static let inputAccessoryWidth: CGFloat = 16
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
        /// Вертикальная поправка для выравнивания иконки с первой строкой комментария.
        static let iconVerticalInset: CGFloat = 1
        /// Диапазон числа видимых строк поля комментария до начала прокрутки.
        static let visibleLines = 1...10
    }
}
