//
//  TripDetailHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI

struct TripDetailHeaderView: View {
    // MARK: - Stored Properties

    let data: TripDetailHeaderData

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: "calendar").foregroundStyle(.secondary)
                Text(data.dateRange).font(.subheadline).foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Image(systemName: "clock").foregroundStyle(.secondary)
                Text(data.durationText).font(.subheadline).foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                AmountCardView(
                    title: "trip.detail.summary.planned",
                    amount: data.plannedAmount,
                    tint: .blue
                )
                AmountCardView(
                    title: "trip.detail.summary.actual",
                    amount: data.actualAmount,
                    tint: .yellow
                )
            }
            
            AmountCardView(
                title: "trip.detail.summary.difference",
                amount: data.amountDifference,
                tint: differenceTint
            )
        }
    }

    private var differenceTint: Color {
        data.amountDifferenceValue >= 0 ? .green : .red
    }
}

private struct AmountCardView: View {
    // MARK: - Stored Properties

    let title: LocalizedStringKey
    let amount: String
    let tint: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)

            Text(amount).font(.headline).foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.1))
        )
    }
}

// MARK: - Preview

private struct PreviewData {
    var headerData: TripDetailHeaderData
    
    init() {
        let builder = PreviewDataBuilder.builder()
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)
        
        self.headerData = viewModel.headerData
    }
}

#Preview("Light - RU") {
    let data = PreviewData()
    
    List {
        TripDetailHeaderView(
            data: data.headerData
        )
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    let data = PreviewData()
    
    List {
        TripDetailHeaderView(
            data: data.headerData
        )
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
    }
}
