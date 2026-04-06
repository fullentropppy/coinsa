//
//  NowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct NowView: View {
    // MARK: - Stored Properties
    
    @Environment(AppSettingsStore.self) private var settingsStore

    @Query(sort: \Location.startDate) private var locations: [Location]

    @State private var selectedLocationID: PersistentIdentifier?
    @State private var selectedQuickCategory: ExpenseCategory?

    // MARK: - Computed Properties

    private var currentLocations: [Location] {
        let today = Date.now
        return locations
            .filter { $0.startDate <= today && $0.endDate >= today }
            .sorted { $0.endDate < $1.endDate }
    }

    private var currentLocationIDs: [PersistentIdentifier] {
        currentLocations.map(\.persistentModelID)
    }

    private var selectedLocation: Location? {
        if let selectedLocationID {
            currentLocations.first(where: { $0.persistentModelID == selectedLocationID }) ?? currentLocations.first
        } else {
            currentLocations.first
        }
    }

    private var recentExpenses: [Expense] {
        if let selectedLocation {
            selectedLocation.expenses
                .sorted { $0.date > $1.date }
                .prefix(3)
                .map { $0 }
        } else {
            []
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if let selectedLocation {
                    nowForm(location: selectedLocation)
                        .sheet(item: $selectedQuickCategory) { selectedCategory in
                            ExpenseEditView(
                                location: selectedLocation,
                                baseCurrency: settingsStore.baseCurrency,
                                preselectedCategory: selectedCategory
                            )
                        }
                } else {
                    emptyCurrentLocationView
                }
            }
            .navigationTitle(.nowNavigationTitle)
            .navigationBarTitleDisplayMode(.large)
        }
        .task(id: currentLocationIDs) {
            updateSelectedLocationIfNeeded()
        }
    }

    // MARK: - Content

    private func nowForm(location: Location) -> some View {
        Form {
            locationSection(location: location)
            quickExpenseSection
            recentExpensesSection
        }
    }
    
    private var emptyCurrentLocationView: some View {
        EmptyStateView(
            imageName: Location.primaryIcon,
            title: .nowEmptyStateTitle,
            description: .nowEmptyStateDescription
        )
    }

    // MARK: - Sections

    private func locationSection(location: Location) -> some View {
        Section {
            VStack(spacing: 14) {
                locationPickerContent(location: location)
                locationHeaderContent(location: location)
                locationSummaryContent(location: location)
            }
        }
    }
    
    private var quickExpenseSection: some View {
        Section(.nowQuickExpense) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.id) { category in
                    quickExpenseButton(category: category)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    private var recentExpensesSection: some View {
        if !recentExpenses.isEmpty {
            Section(.nowRecentExpenses) {
                ForEach(recentExpenses) { expense in
                    NavigationLink {
                        ExpenseDetailView(expense: expense)
                    } label: {
                        ExpenseRowView(expense: expense, baseCurrency: settingsStore.baseCurrency)
                    }
                }
            }
        }
    }

    // MARK: - Components
    
    @ViewBuilder
    private func locationPickerContent(location: Location) -> some View {
        if currentLocations.count > 1 {
            Picker("", selection: selectedLocationBinding(fallbackID: location.persistentModelID)) {
                ForEach(currentLocations) { currentLocation in
                    Text(currentLocation.name)
                        .tag(currentLocation.persistentModelID)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func locationHeaderContent(location: Location) -> some View {
        NavigationLink {
            LocationDetailView(location: location)
        } label: {
            HStack {
                if currentLocations.count == 1 {
                    Text(location.name)
                        .fontWeight(.semibold)
                    Spacer()
                }
                DateLabel.secondarySmall(from: location.startDate, to: location.endDate)
                CountLabel.daysSecondarySmall(location.durationInDays)
            }
        }
    }
    
    private func locationSummaryContent(location: Location) -> some View {
        let viewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: settingsStore.baseCurrency
        )

        return EventSummaryView(data: viewModel.eventHeaderData, showsHeader: false)
    }
    
    private func quickExpenseButton(category: ExpenseCategory) -> some View {
        Button {
            selectedQuickCategory = category
        } label: {
            HStack {
                Image(systemName: category.badgeIcon)
                    .frame(width: 20)
                Text(category.localized)
                    
            }
            .foregroundStyle(.windowBackground)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.glassProminent)
        .tint(category.badgeColor)
    }
    
    // MARK: - Bindings

    private func selectedLocationBinding(fallbackID: PersistentIdentifier) -> Binding<PersistentIdentifier> {
        Binding(
            get: { selectedLocationID ?? fallbackID },
            set: { selectedLocationID = $0 }
        )
    }

    // MARK: - Actions

    private func updateSelectedLocationIfNeeded() {
        guard !currentLocations.isEmpty else {
            selectedLocationID = nil
            return
        }

        if let selectedLocationID,
            currentLocations.contains(where: { $0.persistentModelID == selectedLocationID }) {
            return
        }

        selectedLocationID = currentLocations.first?.persistentModelID
    }
}

// MARK: - Previews

private extension NowView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withLocation: Bool = true,
        withExpenses: Bool = true
    ) -> some View {
        var builder = PreviewBuilder.builder()
        if withLocation {
            builder = builder.withScenario(.southKorea).withExpenses(withExpenses)
        } else {
            builder = builder.withTrips(false)
        }
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)

        return NowView()
            .modelContainer(container)
            .environment(settingsStore)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("No Expenses. Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withExpenses: false)
}

#Preview("No Expenses. Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withExpenses: false)
}

#Preview("Empty. Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withLocation: false, withExpenses: false)
}

#Preview("Empty. Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withLocation: false, withExpenses: false)
}
