//
//  LocationBudgetTransferView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftUI
import SwiftData

/// Выбор локации для переноса всего остатка бюджета.
struct LocationBudgetTransferView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel: LocationBudgetTransferViewModel

    // MARK: - Зависимости

    private let onTransfer: (String) -> Void

    // MARK: - Инициализация

    /// Создает список получателей для переноса остатка существующей локации.
    /// - Parameters:
    ///   - source: Локация, передающая остаток бюджета.
    ///   - onTransfer: Действие после сохранения с названием локации-получателя.
    init(source: Location, onTransfer: @escaping (String) -> Void) {
        _viewModel = State(initialValue: LocationBudgetTransferViewModel(source: source))
        self.onTransfer = onTransfer
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            List {
                availableAmountSection
                destinationSections
            }
            .navigationTitle(Text(.locationBudgetTransferTitle))
            .navigationSubtitle(viewModel.source.trip?.screenContextSubtitle ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarButton.close { dismiss() }
                }
            }
            .alert(
                .locationBudgetTransferConfirmationTitle,
                isPresented: $viewModel.isShowingConfirmation,
                presenting: viewModel.selection
            ) { selection in
                Button(.locationBudgetTransferConfirm) {
                    confirmTransfer(selection)
                }
                Button(.cancel, role: .cancel) {}
            } message: { selection in
                Text(selection.message)
            }
            .notificationAlert(
                isPresented: errorBinding,
                title: .locationBudgetTransferErrorTitle,
                message: viewModel.errorMessage ?? .errorUnknown,
                isError: true
            )
        }
    }

    // MARK: - Секции

    private var availableAmountSection: some View {
        Section {
            LabeledContent {
                AmountStack(
                    homeAmount: viewModel.availableHomeAmount,
                    homeCurrency: viewModel.source.homeCurrency,
                    expenseAmount: viewModel.availableLocationAmount,
                    expenseCurrency: viewModel.source.locationCurrency
                )
            } label: {
                Text(.locationBudgetTransferAvailable)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
            }
        } footer: {
            Text(.locationBudgetTransferHint)
        }
    }

    private var destinationSections: some View {
        ForEach(viewModel.groupedLocations, id: \.status) { group in
            Section(group.status.safeLocalizedResourcePlural) {
                ForEach(group.locations) { location in
                    Button {
                        haptics.trigger(.warning)
                        viewModel.select(location)
                    } label: {
                        LocationRowView(location, showsBudgetBalance: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canTransfer)
                }
            }
        }
    }

    // MARK: - Биндинги

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    // MARK: - Действия

    private func confirmTransfer(_ selection: LocationBudgetTransferViewModel.Selection) {
        let repository = LocationRepository(context: context)
        guard viewModel.transfer(selection, using: repository) != nil else { return }

        onTransfer(selection.destination.name)
        dismiss()
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(.japan, includeLocations: true)
    if let source = trip.locations?.first {
        LocationBudgetTransferView(source: source) { _ in }
    }
}
