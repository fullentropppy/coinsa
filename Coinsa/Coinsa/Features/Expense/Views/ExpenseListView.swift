//
//  ExpenseListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

struct ExpenseListView: View {
    // MARK: - Stored Properties
    
    let location: Location
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ForEach(location.expenses.sorted(by: { $0.date > $1.date })) { expense in
                ExpenseRowView(expense: expense)
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Previews

//#Preview("Light - RU") {
//    ExpenseListView(location: PreviewDataFactory.Builder().getLocation())
//        .environment(\.locale, Locale(identifier: "ru"))
//        .preferredColorScheme(.light)
//}
//
//#Preview("Dark - EN") {
//    ExpenseListView(location: PreviewDataFactory.Builder().getLocation())
//        .environment(\.locale, Locale(identifier: "en"))
//        .preferredColorScheme(.dark)
//}
//
//#Preview("Empty expenses") {
//    ExpenseListView(location: PreviewDataFactory.Builder().withExpenses(false).getLocation())
//}
