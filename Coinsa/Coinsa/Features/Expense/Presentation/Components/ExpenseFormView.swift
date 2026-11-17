//
//  ExpenseFormView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 14.11.2026.
//

import SwiftUI
import SwiftData

/// Форма траты с секциями и привязками к общему черновику и фокусу редактора.
struct ExpenseFormView: View {
    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    @Bindable private var viewModel: ExpenseEditViewModel
    private let currencyPairSide: CurrencyPairSide
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let isCommentFocused: FocusState<Bool>.Binding
    private let isResolvingLocation: Bool
    private let onSwitchInputCurrency: () -> Void
    private let onLocate: () -> Void
    private let onShowMap: () -> Void
    private let onDelete: () -> Void

    // MARK: - Инициализация

    /// Создает секции, используя черновик и управление фокусом родительской формы.
    /// - Parameters:
    ///   - viewModel: Общий черновик траты.
    ///   - currencyPairSide: Текущая сторона ввода суммы.
    ///   - focusedField: Фокус числовых полей, принадлежащий экрану.
    ///   - isCommentFocused: Фокус поля комментария, принадлежащий экрану.
    ///   - isResolvingLocation: Выполняется ли определение координат.
    ///   - onSwitchInputCurrency: Переключение валюты ввода с завершением текущего ввода.
    ///   - onLocate: Запрос текущей геопозиции.
    ///   - onShowMap: Открытие карты для выбора места траты.
    ///   - onDelete: Запрос подтверждения удаления.
    init(
        viewModel: ExpenseEditViewModel,
        currencyPairSide: CurrencyPairSide,
        focusedField: FocusState<NumericEditField?>.Binding,
        isCommentFocused: FocusState<Bool>.Binding,
        isResolvingLocation: Bool,
        onSwitchInputCurrency: @escaping () -> Void,
        onLocate: @escaping () -> Void,
        onShowMap: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.currencyPairSide = currencyPairSide
        self.focusedField = focusedField
        self.isCommentFocused = isCommentFocused
        self.isResolvingLocation = isResolvingLocation
        self.onSwitchInputCurrency = onSwitchInputCurrency
        self.onLocate = onLocate
        self.onShowMap = onShowMap
        self.onDelete = onDelete
    }

    // MARK: - Тело View

    var body: some View {
        Form {
            amountSection
            specificationsSection
            currencySection
            commentSection
            dateSection
            placeOfExpenseSection
            actionsSection
        }
    }

    // MARK: - Секции

    private var amountSection: some View {
        Section {
            VStack {
                NumericInputField(
                    amountInputBinding,
                    focusedField: focusedField,
                    focusID: .amount,
                    fractionDigits: 2,
                    font: .largeTitle,
                    textAlignment: .center,
                    placeholder: viewModel.amountInputPlaceholder
                )
                .id(currencyPairSide)
                HStack {
                    CurrencyCodeText.standard(viewModel.currency(for: currencyPairSide))
                    if !viewModel.isExpensehomeCurrency {
                        InputCurrencySwitchButton(action: onSwitchInputCurrency)
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
    }

    private var specificationsSection: some View {
        Section {
            Picker(selection: categoryBinding) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Image(systemName: category.primaryIcon)
                        .tag(category)
                }
            } label: {
                EmptyView()
            }
            .onChange(of: categoryBinding.id) {
                haptics.trigger(.tap)
            }
            .pickerStyle(.segmented)
            .navigationLinkIndicatorVisibility(.hidden)
            .listRowSeparator(.hidden)

            LabeledPicker(
                title: viewModel.category.localizedResource,
                selection: subcategoryBinding,
                options: viewModel.category.subcategories
            ) { subcategory in
                subcategory.makeLabel()
            }
        }
    }

    private var currencySection: some View {
        Section {
            Picker(.expensePaymentMethod, selection: paymentMethodBinding) {
                ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                    Image(systemName: paymentMethod.primaryIcon)
                       .tag(paymentMethod)
                }
            }
            .onChange(of: paymentMethodBinding.id) {
                haptics.trigger(.tap)
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)

            CurrencyPicker(
                title: .expenseCurrency,
                selection: expenseCurrencyBinding,
                sections: Currency.pickerSections(
                    homeCurrency: viewModel.homeCurrency,
                    locationCurrency: viewModel.locationCurrency
                ),
            ) { currency in
                CurrencyCodeText.standard(currency)
            }

            if viewModel.showsRateExpenseToBase {
                LabeledContent(.expenseExchangeRate(expenseCurrencyCode: viewModel.expenseCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateExpenseToHomeInputBinding,
                        currency: viewModel.homeCurrency,
                        isLoading: viewModel.isRateExpenseToBaseLoading,
                        focusedField: focusedField,
                        focusID: .exchangeRate,
                        onRefresh: { viewModel.requestRateExpenseToBaseRefresh(for: currencyPairSide) }
                    )
                }
            }

            if viewModel.showsRateExpenseToLocation {
                LabeledContent(.expenseExchangeRate(expenseCurrencyCode: viewModel.expenseCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateExpenseToLocationInputBinding,
                        currency: viewModel.locationCurrency,
                        isLoading: viewModel.isRateExpenseToLocationLoading,
                        focusedField: focusedField,
                        focusID: .locationExchangeRate,
                        onRefresh: { viewModel.requestRateExpenseToLocationRefresh() }
                    )
                }
            }

            if viewModel.useExchangeAdjustment {
                LabeledContent(.locationExchangeAdjustment) {
                    PercentInputField.standard(
                        exchangeAdjustmentInputBinding,
                        focusedField: focusedField,
                        focusID: .exchangeAdjustment
                    )
                }
            }
        } footer: {
            if let adjustedRateDescription = viewModel.adjustedRateDescription {
                Text(adjustedRateDescription)
            }
        }
    }

    private var dateSection: some View {
        Section {
            DatePicker(
                selection: $viewModel.date
            ) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text(.expenseDate)
                }
            }
            .environment(\.timeZone, .utc)
        } footer: {
            Text(
                .expenseTimeZoneHint(
                    gmtOffsetDisplay: viewModel.timeZone.gmtOffsetDisplay,
                    timeZoneID: viewModel.timeZone.identifier
                )
            )
        }
    }

    private var placeOfExpenseSection: some View {
        Section {
            if let coordinate = viewModel.coordinate {
                Button {
                    onShowMap()
                } label: {
                    CompactMapView(
                        Binding(
                            get: { viewModel.coordinate ?? coordinate },
                            set: { viewModel.updateCoordinate($0) }
                        ),
                        markerTitle: .expensePlace,
                        markerSystemImage: viewModel.subcategory.secondaryIcon,
                        markerTint: viewModel.subcategory.accentColor
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onLocate) {
                    HStack {
                        Image(systemName: "location")
                        Text(.expensePlaceLocate)
                    }
                }
                .disabled(isResolvingLocation)

                Button {
                    haptics.trigger(.tap)
                    onShowMap()
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text(.expensePlaceChoose)
                    }
                }
            }
        } footer: {
            if let coordinate = viewModel.coordinate {
                HStack {
                    HStack {
                        Image(systemName: "location.fill")
                            .imageScale(.small)
                        Text(coordinate.formattedDescription)
                    }
                    .font(.footnote.monospacedDigit())
                    Spacer()
                    ClearButton {
                        viewModel.updateCoordinate(nil)
                    }
                }
            } else {
                Text(.expensePlaceHint)
            }
        }
    }

    private var commentSection: some View {
        Section {
            HStack {
                Image(systemName: "ellipsis.bubble")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, ViewLayout.Comment.iconVerticalInset)
                    .frame(maxHeight: .infinity, alignment: .topLeading)

                TextField(.expenseComment, text: $viewModel.comment, axis: .vertical)
                    .lineLimit(ViewLayout.Comment.visibleLines)
                    .focused(isCommentFocused)
                    .keyboardClearAction(text: $viewModel.comment)
            }
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEdit {
            Section {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(.expenseDelete)
                    }
                }
            }
        }
    }

    // MARK: - Биндинги

    private var categoryBinding: Binding<ExpenseCategory> {
        Binding(
            get: { viewModel.category },
            set: { viewModel.updateCategory($0) }
        )
    }

    private var subcategoryBinding: Binding<ExpenseSubcategory> {
        Binding(
            get: { viewModel.subcategory },
            set: { viewModel.subcategory = $0 }
        )
    }

    private var paymentMethodBinding: Binding<PaymentMethod> {
        Binding(
            get: { viewModel.paymentMethod },
            set: { newMethod in
                viewModel.updatePaymentMethod(newMethod, currencyPairSide: currencyPairSide)
                settingsStore.selectedPaymentMethod = newMethod
            }
        )
    }

    private var expenseCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.expenseCurrency },
            set: { newCurrency in
                viewModel.updateExpenseCurrency(newCurrency, currencyPairSide: currencyPairSide)
            }
        )
    }

    private var amountInputBinding: Binding<Double> {
        let inputSide = currencyPairSide
        return Binding(
            get: { viewModel.amount(for: inputSide) },
            set: { newValue in
                viewModel.updateAmount(newValue, for: inputSide)
            }
        )
    }

    private var rateExpenseToHomeInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateExpenseToHome },
            set: { newValue in
                viewModel.updateRateExpenseToBase(newValue, currencyPairSide: currencyPairSide)
            }
        )
    }

    private var rateExpenseToLocationInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateExpenseToLocation },
            set: { newValue in
                viewModel.updateRateExpenseToLocation(newValue)
            }
        )
    }

    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.exchangeAdjustment },
            set: { newValue in
                viewModel.updateExchangeAdjustment(newValue, currencyPairSide: currencyPairSide)
            }
        )
    }

}

// MARK: - Превью

private struct ExpenseFormPreview: View {
    let preview: ExpenseFormPreviewData

    @State private var currencyPairSide: CurrencyPairSide = .quote
    @FocusState private var focusedField: NumericEditField?
    @FocusState private var isCommentFocused: Bool

    var body: some View {
        NavigationStack {
            if let viewModel = preview.viewModel {
                ExpenseFormView(
                    viewModel: viewModel,
                    currencyPairSide: currencyPairSide,
                    focusedField: $focusedField,
                    isCommentFocused: $isCommentFocused,
                    isResolvingLocation: false,
                    onSwitchInputCurrency: {
                        focusedField = nil
                        currencyPairSide = currencyPairSide == .base ? .quote : .base
                    },
                    onLocate: {},
                    onShowMap: {},
                    onDelete: {}
                )
                .keyboardInputBar(isPresented: focusedField != nil || isCommentFocused) {
                    focusedField = nil
                    isCommentFocused = false
                }
            }
        }
    }
}

#Preview("Editing") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    ExpenseFormPreview(preview: preview)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}

#Preview("Creating") {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: false)

    ExpenseFormPreview(preview: preview)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}
