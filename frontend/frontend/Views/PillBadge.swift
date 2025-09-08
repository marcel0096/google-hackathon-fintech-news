//
//  PillBadge.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

enum Impact: String { case high, medium, low }

struct PillBadge: View {
    var text: String
    var impact: Impact

    private var colors: (bg: Color, fg: Color, border: Color) {
        switch impact {
        case .high:   return (
            Color.red.opacity(0.18),
            Color.red.opacity(0.9),
            Color.red.opacity(0.35)
        )
        case .medium: return (
            Finora.warning.opacity(0.18),
            Finora.warning,
            Finora.warning.opacity(0.35)
        )
        case .low:    return (
            Finora.success.opacity(0.18),
            Finora.success,
            Finora.success.opacity(0.35)
        )
        }
    }

    var body: some View {
        Text(text)
            .font(.caption).fontWeight(.semibold)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Capsule().fill(colors.bg))
            .overlay(Capsule().stroke(colors.border, lineWidth: 1))
            .foregroundStyle(colors.fg)
    }
}
