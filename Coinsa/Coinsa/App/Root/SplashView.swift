//
//  SplashView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.04.2026.
//

import SwiftUI

struct SplashView: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    @State private var backgroundOpacity = 1.0
    @State private var iconScale = 0.8
    @State private var iconOpacity = 0.0
    @State private var hasStartedAnimation = false

    // MARK: - Зависисмости
    
    let onFinished: () -> Void
    
    // MARK: - Тело View

    var body: some View {
        Color.accent
            .overlay {
                Image(systemName: "lizard.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.windowBackground)
                    .opacity(iconOpacity)
                    .scaleEffect(iconScale)
            }
            .opacity(backgroundOpacity)
            .ignoresSafeArea()
            .task {
                await runAnimationIfNeeded()
            }
    }

    // MARK: - Внутренние методы

    @MainActor
    private func runAnimationIfNeeded() async {
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true
        
        withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
            iconOpacity = 1
            iconScale = 1
        }
        
        try? await Task.sleep(for: .milliseconds(200))
        haptics.trigger(.add)
        
        try? await Task.sleep(for: .milliseconds(200))
        haptics.trigger(.tap)
        
        withAnimation(.spring(response: 0.46, dampingFraction: 0.82)) {
            iconOpacity = 0
            iconScale = 0
            backgroundOpacity = 0
        }

        try? await Task.sleep(for: .milliseconds(2000))
        
        onFinished()
    }
}

// MARK: - Превью

#Preview("Light") {
    TimelineView(.periodic(from: .now, by: 2.0)) { timeline in
        SplashView(onFinished: {})
            .id(timeline.date.timeIntervalSince1970)
            .preferredColorScheme(.light)
    }
}

#Preview("Dark") {
    TimelineView(.periodic(from: .now, by: 2.0)) { timeline in
        SplashView(onFinished: {})
            .id(timeline.date.timeIntervalSince1970)
            .preferredColorScheme(.dark)
    }
}

