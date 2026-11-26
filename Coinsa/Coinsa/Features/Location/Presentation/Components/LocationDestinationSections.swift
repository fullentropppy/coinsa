//
//  LocationDestinationSections.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import SwiftUI
import SwiftData

/// Список локаций назначения для трат и переноса остатка бюджета.
struct LocationDestinationSections: View {
    // MARK: - Свойства

    private let groups: [(status: EventStatus, locations: [Location])]
    private let title: LocalizedStringResource?
    private let icon: String
    private let showsBudgetBalance: Bool
    private let isEnabled: Bool
    private let onSelect: (Location) -> Void

    // MARK: - Инициализация

    /// Создает секции выбора, оставляя проверку и выполнение операции вызывающему экрану.
    /// - Parameters:
    ///   - groups: Подготовленные группы локаций в порядке отображения.
    ///   - title: Название группы назначений; nil скрывает общий заголовок.
    ///   - icon: Системная иконка общего заголовка.
    ///   - showsBudgetBalance: Показывать остатки бюджетов вместо счетчиков трат и дней.
    ///   - isEnabled: Разрешать выбор назначения.
    ///   - onSelect: Действие при выборе локации.
    init(
        groups: [(status: EventStatus, locations: [Location])],
        title: LocalizedStringResource? = nil,
        icon: String = Location.primaryIcon,
        showsBudgetBalance: Bool = false,
        isEnabled: Bool = true,
        onSelect: @escaping (Location) -> Void
    ) {
        self.groups = groups
        self.title = title
        self.icon = icon
        self.showsBudgetBalance = showsBudgetBalance
        self.isEnabled = isEnabled
        self.onSelect = onSelect
    }

    // MARK: - Тело View

    var body: some View {
        if let title {
            GroupHeader(
                icon: icon,
                title: title,
                itemCount: groups.reduce(0) { $0 + $1.locations.count }
            )
            .listRowBackground(Color.clear)
        }

        ForEach(groups, id: \.status) { group in
            Section(group.status.safeLocalizedResourcePlural) {
                ForEach(group.locations) { location in
                    Button {
                        onSelect(location)
                    } label: {
                        LocationRowView(location, showsBudgetBalance: showsBudgetBalance)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                }
            }
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData(.asia, includeLocations: true)

    List {
        LocationDestinationSections(
            groups: LocationGrouping.grouped(preview.trip.locations ?? []),
            title: .locationBudgetTransferRecipientLocations,
            icon: AppSymbols.trayAndArrowDown,
            showsBudgetBalance: true,
            onSelect: { _ in }
        )
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(.asia, includeLocations: true)

    List {
        LocationDestinationSections(
            groups: LocationGrouping.grouped(preview.trip.locations ?? []),
            title: .expenseDestinationLocations,
            onSelect: { _ in }
        )
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
