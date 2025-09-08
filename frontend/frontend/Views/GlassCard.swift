//
//  GlassCard.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var fixedHeight: CGFloat? = nil // optional fixed height
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity)
        .frame(height: fixedHeight)
        .finoraGlassCard()
    }
}
