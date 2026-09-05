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
    @State private var mapMarkerPosition: MapCameraPosition
    
    private let expense: Expense
        
    // MARK: - Вычисляемые свойства

    private var viewModel: ExpenseDetailViewModel {
        ExpenseDetailViewModel(expense: expense)
    }

    private var formBackgroundVisibility: Visibility {
        viewModel.coordinate == nil ? .visible : .hidden
    }
    
    private var formBackgroundGradient: LinearGradient {
        var lastStopLocation = 0.65
        
        if viewModel.isExpenseBaseCurrency {
            lastStopLocation -= 0.1
        }
        
        if expense.comment == nil {
            lastStopLocation -= 0.1
        }

        return LinearGradient(
            stops:
                [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: lastStopLocation - 0.15),
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
        if let cameraCoordinate = viewModel.cameraCoreCoordinate {
            .camera(MapCamera(centerCoordinate: cameraCoordinate, distance: 10000))
        } else {
            nil
        }
    }
    
    // MARK: - Инициализация

    init(_ expense: Expense) {
        self.expense = expense
        self.mapMarkerPosition = .automatic
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
                        title: .expensePlaceOfExpense
                    )
                }
            }
            .onAppear {
                checkIfDeleted()
            }
    }

    // MARK: - Основной контент
    
    private var expenseDetailForm: some View {
        ZStack {
            backgroundContent
            
            Form {
                mainSection
                commentSection
            }
            .scrollContentBackground(formBackgroundVisibility)
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
            RoundedRectangle(cornerRadius: 0).fill(listRowBackgroundMaterial)
        )
    }
    
    @ViewBuilder
    private var commentSection: some View {
        if let comment = expense.comment {
            Section {
                HStack {
                    Image(systemName: "ellipsis.bubble")
                        .foregroundStyle(.secondary)
                    
                    Text(comment)
                }
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 0).fill(listRowBackgroundMaterial)
            )
        }
    }
    
    @ViewBuilder
    private var mapSection: some View {
        if let coordinate = expense.coordinate {
            Section {
                Button {
                    isShowingMap = true
                } label: {
                    CompactMapView(coordinate, title: .expensePlaceOfExpense)
                }
                .buttonStyle(.plain)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
    
    // MARK: - Компоненты
    
    @ViewBuilder

    private var backgroundContent: some View {
        if let coordinate = viewModel.coordinate, let mapCameraPosition {
            Map(position: $mapMarkerPosition) {
                Marker("", coordinate: coordinate)
            }
            .onAppear {
                mapMarkerPosition = mapCameraPosition
            }
            .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial)
                .mask {
                    formBackgroundGradient
                }
                .ignoresSafeArea()
        }
    }
    
    private var headerContent: some View {
        HStack {
            Expense.makeBadge()
            expense.subcategory.makeBadge()
            Spacer()
            DateLabel.secondarySmall(expense.civilDateTime)
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
            
            HStack(spacing: 6) {
                Image(systemName: expense.paymentMethod.primaryIcon)
                    .imageScale(.medium)
                    .fontWeight(.semibold)
            }
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

private extension ExpenseDetailView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        let expense = builder.getExpense(from: data)
        
        return NavigationStack {
            ExpenseDetailView(expense)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseDetailView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
