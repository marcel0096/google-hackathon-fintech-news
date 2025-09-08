//
//  RiskSlider.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct RiskSlider: View {
    @Binding var value: Double // 0...10
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Risk").foregroundStyle(Finora.textMuted)
                Spacer()
                Text(String(format: "%.1f/10", value))
                    .foregroundStyle(Finora.textSecondary)
            }.font(.caption)

            Slider(value: $value, in: 0...10, step: 0.1)
                .tint(Finora.primary)
        }
    }
}
