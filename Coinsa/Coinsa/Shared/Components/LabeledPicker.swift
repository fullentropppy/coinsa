//
//  LabeledPicker.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.04.2026.
//

import SwiftUI

struct LabeledPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Properties
    let title: LocalizedStringResource
    let selection: Binding<SelectionValue>
    let options: [SelectionValue]
    @ViewBuilder let content: (SelectionValue) -> Content
    
    // MARK: - Initializers
    init(
        title: LocalizedStringResource,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self.selection = selection
        self.options = options
        self.content = content
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    content(option)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)
            .navigationLinkIndicatorVisibility(.hidden)
            
            Image(systemName: "chevron.right")
                .fontWeight(.semibold)
                .imageScale(.small)
                .foregroundStyle(.accent)
        }
    }
}
