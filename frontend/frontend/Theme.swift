//
//  Theme.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

enum Finora {
    // Colors approximated from your HSL tokens in src/index.css
    static let background = Color(
        red: 0x0A/255,
        green: 0x0F/255,
        blue: 0x1C/255
    ) // #0A0F1C
    static let surface     = Color(
        red: 0x14/255,
        green: 0x1C/255,
        blue: 0x2B/255
    ) // ~lighter navy
    static let glass       = Color(
        red: 0x19/255,
        green: 0x24/255,
        blue: 0x36/255
    ) // frosted base

    static let primary     = Color(
        red: 0x3D/255,
        green: 0xD9/255,
        blue: 0xD4/255
    ) // #3DD9D4
    static let secondary   = Color(
        red: 0xD4/255,
        green: 0xC3/255,
        blue: 0xF0/255
    ) // #D4C3F0

    static let textPrimary   = Color.white
    static let textSecondary = Color(white: 0.78)
    static let textMuted     = Color(white: 0.62)

    static let success = Color(hue: 120/360, saturation: 0.70, brightness: 0.60)
    static let danger  = Color(hue:   0/360, saturation: 0.70, brightness: 0.60)
    static let warning = Color(hue:  45/360, saturation: 0.95, brightness: 0.65)

    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 16
    static let radiusLG: CGFloat = 24
    static let radiusXL: CGFloat = 32
}

extension View {
    func finoraGlassCard() -> some View {
        self
            .background(.ultraThinMaterial) // frosted
            .overlay(
                RoundedRectangle(cornerRadius: Finora.radiusLG)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Finora.radiusLG))
            .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 12)
    }
}
