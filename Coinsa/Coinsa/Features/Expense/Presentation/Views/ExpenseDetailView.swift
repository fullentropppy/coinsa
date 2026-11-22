//
//  ExpenseDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import SwiftUI
import SwiftData
import MapKit

/// Детальный экран траты.
struct ExpenseDetailView: View {
    // MARK: - Константы

    private enum Layout {
        /// Половина ширины перехода маски фона в долях высоты экрана.
        static let gradientTransitionHalfWidth: CGFloat = 0.1
        /// Расстояние камеры фоновой карты до места траты в метрах.
        static let mapCameraDistance: Double = 10_000
        /// Делитель верхнего отступа карты, определяющего вертикальную позицию маркера.
        static let mapTopInsetDivisor: CGFloat = 1.2
        /// Множитель высоты при расчете границы градиентной маски.
        static let gradientHeightMultiplier: CGFloat = 1.2
        /// Отступы блоков сумм внутри карточки подробностей траты.
        static let amountBlockInset: CGFloat = 10
        /// Интервал под подписью способа оплаты перед основной суммой.
        static let paymentLabelBottomInset: CGFloat = 2
    }

    nonisolated private enum ContentSpace: Hashable {
        case form
    }

    // MARK: - Хранимые свойства

    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @Environment(\.haptics) private var haptics
    
    @State private var isShowingExpenseEdit = false
    @State private var isShowingExpenseCopy = false
    @State private var isShowingMap = false
    @State private var isVisible = false
    @State private var contentBottom: CGFloat = 0
    
    private let expense: Expense
        
    // MARK: - Вычисляемые свойства

    private var viewModel: ExpenseDetailViewModel {
        ExpenseDetailViewModel(expense: expense)
    }

    private func formBackgroundGradient(contentInset: CGFloat, height: CGFloat) -> LinearGradient {
        let lastStopLocation = contentInset / max(height, 1)

        return LinearGradient(
            stops:
                [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: max(lastStopLocation - Layout.gradientTransitionHalfWidth, 0)),
                    .init(color: .clear, location: min(lastStopLocation + Layout.gradientTransitionHalfWidth, 1))
                ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Инициализация

    /// Создает экран подробностей переданной траты.
    init(_ expense: Expense) {
        self.expense = expense
    }
    
    // MARK: - Тело View

    var body: some View {
        expenseDetailForm
            .navigationTitle(viewModel.navigationTitle)
            .navigationSubtitle(viewModel.navigationSubtitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingExpenseEdit) {
                ExpenseEditorView(forEdit: expense) {
                    dismiss()
                }
            }
            .sheet(isPresented: $isShowingExpenseCopy) {
                ExpenseCopyView(source: expense)
            }
            .fullScreenCover(isPresented: $isShowingMap) {
                if let coordinate = expense.coordinate {
                    FullScreenMapView(
                        coordinate: coordinate,
                        title: viewModel.expense.subcategory.localizedResource,
                        markerTitle: .expensePlace,
                        markerSystemImage: expense.subcategory.secondaryIcon,
                        markerTint: expense.subcategory.accentColor
                    )
                }
            }
            .onAppear {
                isVisible = true
                checkIfDeleted()
            }
            .onDisappear {
                isVisible = false
            }
    }

    // MARK: - Основной контент
    
    private var expenseDetailForm: some View {
        GeometryReader { geometry in
            let visibleFrame = geometry.frame(in: .named(ContentSpace.form))

            ZStack {
                backgroundContent(
                    safeAreaBottom: visibleFrame.maxY
                )

                Form {
                    mainSection(visibleFrame: visibleFrame)
                    commentSection(visibleFrame: visibleFrame)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .coordinateSpace(name: ContentSpace.form)
        .onTapGesture {
            if viewModel.coordinate != nil {
                isShowingMap = true
            }
        }
    }
    
    // MARK: - Секции

    private func mainSection(visibleFrame: CGRect) -> some View {
        Section {
            VStack(spacing: ViewLayout.Summary.sectionSpacing) {
                headerContent
                cardContent
                additionalInfoContent
            }
        }
        .listRowBackground(
            sectionBackground(isLast: expense.comment == nil, visibleFrame: visibleFrame)
        )
    }
    
    @ViewBuilder
    private func commentSection(visibleFrame: CGRect) -> some View {
        if let comment = expense.comment {
            Section {
                HStack(alignment: .top) {
                    Image(systemName: "ellipsis.bubble")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, ViewLayout.Comment.iconVerticalInset)

                    Text(comment)
                }
            }
            .listRowBackground(
                sectionBackground(isLast: true, visibleFrame: visibleFrame)
            )
        }
    }
    
    // MARK: - Компоненты
    
    @ViewBuilder
    private func backgroundContent(safeAreaBottom: CGFloat) -> some View {
        if isVisible, let coordinate = viewModel.coordinate {
            GeometryReader { geometry in
                let frame = geometry.frame(in: .named(ContentSpace.form))
                let bottomInset = min(max(frame.maxY - safeAreaBottom, 0), geometry.size.height)
                let topInset = min(max(contentBottom - frame.minY, 0), geometry.size.height - bottomInset)

                ZStack {
                    Map(position: .constant(.camera(MapCamera(centerCoordinate: coordinate, distance: Layout.mapCameraDistance)))) {
                        Marker("", systemImage: expense.subcategory.secondaryIcon, coordinate: coordinate)
                            .tint(expense.subcategory.accentColor)
                    }
                    .safeAreaPadding(EdgeInsets(
                        top: topInset / Layout.mapTopInsetDivisor,
                        leading: 0,
                        bottom: bottomInset,
                        trailing: 0
                    ))

                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask {
                            formBackgroundGradient(
                                contentInset: topInset,
                                height: geometry.size.height * Layout.gradientHeightMultiplier
                            )
                        }
                }
            }
            .ignoresSafeArea()
        } else {
            DaySegmentBackground(daySegment: .from(civilDateTime: expense.civilDateTime))
        }
    }

    private func sectionBackground(isLast: Bool, visibleFrame: CGRect) -> some View {
        let tracksContentBottom = isLast && isVisible && viewModel.coordinate != nil
        let scale = displayScale

        return RoundedRectangle(cornerRadius: 0)
            .fill(.regularMaterial)
            .onGeometryChange(for: CGFloat?.self) { geometry in
                guard tracksContentBottom else { return nil }
                let bottom = geometry.frame(in: .named(ContentSpace.form)).maxY
                let roundedBottom = (bottom * scale).rounded() / scale
                return min(max(roundedBottom, visibleFrame.minY), visibleFrame.maxY)
            } action: { bottom in
                if let bottom {
                    contentBottom = bottom
                }
            }
    }
    
    private var headerContent: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            expense.subcategory.makeBadge()
            Spacer()
            DateLabel.secondarySmall(expense.civilDateTime)
            DotDivider.secondarySmall()
            Text(expense.timeZone.gmtOffsetDisplay)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading) {
            HStack(spacing: ViewLayout.Label.iconSpacing) {
                Image(systemName: expense.paymentMethod.primaryIcon)
                    .fontWeight(.medium)
                Text(expense.paymentMethod == .card ? .expensePaidByCard : .expensePaidInCash)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.leading, Layout.amountBlockInset)
            .padding(.top, Layout.amountBlockInset)
            .padding(.bottom, Layout.paymentLabelBottomInset)
            
            AmountText(
                viewModel.primaryAmount,
                font: .title,
                currency: viewModel.primaryCurrency,
                currencyFont: .title.monospaced(),
                currencyColor: .secondary
            )
            .padding(.leading, Layout.amountBlockInset)
            .padding(.bottom, Layout.amountBlockInset)
            
            if let secondaryAmount = viewModel.secondaryAmount,
               let secondaryCurrency = viewModel.secondaryCurrency {
                Divider()
                
                AmountText(
                    secondaryAmount,
                    font: .body.monospacedDigit(),
                    color: .secondary,
                    currency: secondaryCurrency,
                    currencyFont: .body.monospaced()
                )
                .padding(Layout.amountBlockInset)
            }
        }
        .padding(ViewLayout.Card.contentInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: ViewLayout.Card.cornerRadius, style: .continuous))
    }
    
    @ViewBuilder
    private var additionalInfoContent: some View {
        if let adjustedRateDescription = viewModel.exchangeRateDescription {
            Text(adjustedRateDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            DetailActionsMenu(title: .expenseActions, onEdit: {
                isShowingExpenseEdit = true
            }) {
                Button {
                    haptics.trigger(.tap)
                    isShowingExpenseCopy = true
                } label: {
                    Label(.expenseCopyAction, systemImage: "doc.on.doc")
                }
            }
        }
    }
    
    // MARK: - Действия
    
    private func checkIfDeleted() {
        if expense.modelContext == nil {
            dismiss()
        }
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var preview = ExpenseFormPreviewData(isEditing: true)

    if let expense = preview.viewModel?.expense {
        NavigationStack {
            ExpenseDetailView(expense)
        }
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
    }
}
