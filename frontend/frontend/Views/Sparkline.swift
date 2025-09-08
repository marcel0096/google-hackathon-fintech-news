//
//  SparkLine.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct Sparkline: View {
    var points: [Double] // 0..1 normalized
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let path = Path { p in
                guard let first = points.first else { return }
                p.move(to: CGPoint(x: 0, y: h * (1 - first)))
                for (i, v) in points.enumerated() {
                    let x = w * CGFloat(i) / CGFloat(max(points.count - 1, 1))
                    let y = h * CGFloat(1 - v)
                    p.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.stroke(Finora.primary, lineWidth: 2)
        }
        .frame(height: 28)
    }
}
