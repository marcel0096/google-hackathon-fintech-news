//
//  ProgressRing.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct ProgressRing: View {
    var progress: Double // 0...1

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Finora.primary, Finora.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.headline).bold().foregroundStyle(Finora.textPrimary)
        }
        .frame(width: 84, height: 84)
    }
}
