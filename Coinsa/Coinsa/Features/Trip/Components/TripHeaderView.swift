//
//  TripDetailHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI

struct TripHeaderView: View {
    // MARK: - Stored Properties

    let data: TripDetailHeaderData
    let showsSummary: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                EventStatusLabelView(status: data.status)
                Spacer()
                EventIntervalView(startDate: data.startDate, endDate: data.endDate)
                Spacer()
                EventDurationView(days: data.durationDays)
            }

            if showsSummary {
                HStack(spacing: 10) {
                    TripAmountCardView(
                        title: "trip.detail.summary.planned",
                        amount: data.plannedAmount,
                        currencyCode: data.currencyCode,
                        tint: .blue
                    )
                    TripAmountCardView(
                        title: "trip.detail.summary.actual",
                        amount: data.actualAmount,
                        currencyCode: data.currencyCode,
                        tint: .yellow
                    )
                }

                TripAmountCardView(
                    title: "trip.detail.summary.difference",
                    amount: data.amountDifference,
                    currencyCode: data.currencyCode,
                    tint: differenceTint
                )
            }
        }
    }
    
    private var differenceTint: Color {
        data.amountDifference >= 0 ? .green : .red
    }
}

// MARK: - Preview

private struct PreviewData {
    var headerData: TripDetailHeaderData
    
    init() {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)
        
        self.headerData = viewModel.headerData
    }
}

#Preview("Light - RU") {
    let data = PreviewData()
    
    List {
        TripHeaderView(
            data: data.headerData,
            showsSummary: true
        )
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    let data = PreviewData()
    
    List {
        TripHeaderView(
            data: data.headerData,
            showsSummary: true
        )
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
    }
}
