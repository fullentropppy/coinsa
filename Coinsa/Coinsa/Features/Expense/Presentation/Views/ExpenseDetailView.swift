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
    // MARK: - Хранимые свойства

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingExpenseEdit = false
    @State private var isShowingMap = false
    @State private var contentBottom: CGFloat = 0
    
    private let expense: Expense
        
    // MARK: - Вычисляемые свойства

    private var viewModel: ExpenseDetailViewModel {
        ExpenseDetailViewModel(expense: expense)
    }

    private var formBackgroundVisibility: Visibility {
        viewModel.coordinate == nil ? .visible : .hidden
    }
    
    private func formBackgroundGradient(in geometry: GeometryProxy) -> LinearGradient {
        let lastStopLocation = min(
            max((contentBottom - geometry.frame(in: .global).minY) / max(geometry.size.height, 1), 0), 1
        )

        return LinearGradient(
            stops:
                [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: max(lastStopLocation - 0.1, 0)),
                    .init(color: .clear, location: lastStopLocation)
                ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var listRowBackgroundMaterial: Material {
        if viewModel.coordinate == nil {
            .bar
        } else {
            colorScheme == .light ? .regularMaterial : .thinMaterial
        }
    }
        
    private var mapCameraPosition: MapCameraPosition? {
        if let cameraCoordinate = viewModel.coordinate {
            .camera(MapCamera(centerCoordinate: cameraCoordinate, distance: 10000))
        } else {
            nil
        }
    }
    
    // MARK: - Инициализация

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
                ExpenseEditView(forEdit: expense) {
                    dismiss()
                }
            }
            .fullScreenCover(isPresented: $isShowingMap) {
                if let coordinate = expense.coordinate {
                    FullScreenMapView(
                        coordinate: coordinate,
                        title: viewModel.expense.subcategory.localizedResource,
                        markerTitle: .expensePlaceOfExpense
                    )
                }
            }
            .onAppear {
                checkIfDeleted()
            }
    }

    // MARK: - Основной контент
    
    private var expenseDetailForm: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundContent(
                    topInset: min(
                        max(contentBottom - geometry.frame(in: .global).minY, 0),
                        geometry.size.height
                    )
                )

                Form {
                    mainSection
                    commentSection
                }
                .scrollContentBackground(formBackgroundVisibility)
            }
        }
        .onTapGesture {
            isShowingMap = true
        }
    }
    
    // MARK: - Секции

    private var mainSection: some View {
        Section {
            VStack(spacing: 14) {
                headerContent
                cardContent
                additionalInfoContent
            }
        }
        .listRowBackground(
            sectionBackground(isLast: expense.comment == nil)
        )
    }
    
    @ViewBuilder
    private var commentSection: some View {
        if let comment = expense.comment {
            Section {
                HStack {
                    Image(systemName: "ellipsis.bubble")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 1)
                        .frame(maxHeight: .infinity, alignment: .topLeading)

                    Text(comment)
                }
            }
            .listRowBackground(
                sectionBackground(isLast: true)
            )
        }
    }
    
    // MARK: - Компоненты
    
    @ViewBuilder
    private func backgroundContent(topInset: CGFloat) -> some View {
        if let coordinate = viewModel.coordinate, let mapCameraPosition {
            Map(position: .constant(mapCameraPosition)) {
                Marker("", coordinate: coordinate)
            }
            .safeAreaPadding(.top, topInset)

            Rectangle()
                .fill(.ultraThinMaterial)
                .mask {
                    GeometryReader { geometry in
                        formBackgroundGradient(in: geometry)
                    }
                }
                .ignoresSafeArea()
        }
    }

    private func sectionBackground(isLast: Bool) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(listRowBackgroundMaterial)
            .onGeometryChange(for: CGFloat?.self) { geometry in
                isLast ? geometry.frame(in: .global).maxY : nil
            } action: { bottom in
                if let bottom {
                    contentBottom = bottom
                }
            }
    }
    
    private var headerContent: some View {
        HStack(spacing: 4) {
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
        VStack(alignment: .center) {
            AmountText(
                viewModel.primaryAmount,
                font: .title,
                currency: viewModel.primaryCurrency,
                currencyFont: .title.monospaced(),
                currencyColor: .secondary
            )
            .padding(.top, 28)
            .padding(.bottom, 14)
            
            Image(systemName: expense.paymentMethod.primaryIcon)
                .imageScale(.medium)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.bottom, 28)
            
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
                .padding(14)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            ToolbarButton.edit {
                isShowingExpenseEdit = true
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
    NavigationStack {
        ExpenseDetailView(PreviewGenerator.makeExampleExpense())
    }
}
