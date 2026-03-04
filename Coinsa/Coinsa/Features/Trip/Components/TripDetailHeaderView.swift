//
//  TripDetailHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI

struct TripDetailHeaderView: View {
    // MARK: - Stored Properties

    let dateRange: String
    let plannedAmount: String
    let actualAmount: String

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(dateRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                AmountCardView(
                    title: "trip.detail.summary.planned",
                    amount: plannedAmount,
                    tint: .blue
                )

                AmountCardView(
                    title: "trip.detail.summary.actual",
                    amount: actualAmount,
                    tint: .orange
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
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
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(amount)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }
}
