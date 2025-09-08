//
//  DashboardView.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let impact: Impact
    let time: String
}

struct NewsHighlight: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let time: String
    let trending: Bool
}

struct DashboardView: View {
    // Mock data
    let insights: [Insight] = [
        .init(title: "Fed Rate Decision Impact",
              summary: "Market expects 0.25% cut. Tech likely to benefit.",
              impact: .high, time: "2h ago"),
        .init(title: "Q3 Earnings Season",
              summary: "Volatility ahead; watch mega-cap results.",
              impact: .medium, time: "4h ago"),
        .init(title: "Oil Price Volatility",
              summary: "Energy sector uncertainty, consider defense.",
              impact: .low, time: "6h ago")
    ]

    let news: [NewsHighlight] = [
        .init(title: "Tesla drops 6% after Q3 miss",
              summary: "Revenue lower than expected amid production challenges...",
              source: "Reuters", time: "1h ago", trending: true),
        .init(title: "Bitcoin surges past $45K",
              summary: "Institutions increase adoption...",
              source: "Bloomberg", time: "3h ago", trending: false),
        .init(title: "Fed signals potential 2024 cuts",
              summary: "Dovish shift as inflation slows...",
              source: "WSJ", time: "5h ago", trending: false)
    ]

    @State private var risk: Double = 5.5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good morning!")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Finora.textPrimary)
                        Text("Stay informed, invest smarter")
                            .foregroundStyle(Finora.textMuted)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Finora.textSecondary)
                }
                .padding(.horizontal)

                // News
                VStack(spacing: 12) {
                    HStack {
                        Text("News Highlights").font(.headline)
                        Spacer()
                    }.foregroundStyle(Finora.textPrimary)
                    ForEach(news) { n in
                        GlassCard {
                            HStack {
                                Text(n.title).font(.subheadline).bold()
                                if n.trending { Text("🚀").font(.caption) }
                            }
                            Text(n.summary)
                                .foregroundStyle(Finora.textSecondary)
                                .font(.footnote)
                            HStack {
                                HStack(spacing: 8) {
                                    Text(n.source)
                                        .foregroundStyle(Finora.textMuted)
                                        .font(.caption)
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                        .foregroundStyle(Finora.textMuted)
                                    Text(n.time)
                                        .foregroundStyle(Finora.textMuted)
                                        .font(.caption)
                                }
                                Spacer()
                                Button("Read more") {}
                                    .font(.caption)
                                    .foregroundStyle(Finora.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Top 3 Insights
                VStack(spacing: 12) {
                    HStack {
                        Text("AI Top 3 Insights").font(.headline)
                        Spacer()
                        Button("View All") {}
                            .buttonStyle(.bordered)
                    }.foregroundStyle(Finora.textPrimary)

                    ForEach(insights) { i in
                        GlassCard {
                            HStack {
                                PillBadge(
                                    text: i.impact.rawValue.capitalized,
                                    impact: i.impact
                                )
                                Spacer()
                                Text(i.time)
                                    .font(.caption)
                                    .foregroundStyle(Finora.textMuted)
                            }
                            Text(i.title).font(.subheadline).bold()
                            Text(i.summary)
                                .font(.footnote)
                                .foregroundStyle(Finora.textSecondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Microsavings teaser (ProgressRing + RiskSlider)
                GlassCard {
                    HStack(spacing: 16) {
                        ProgressRing(progress: 0.66)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Microsavings").font(.headline)
                            Text("Round-ups enabled • Goal: €5,000")
                                .font(.caption)
                                .foregroundStyle(Finora.textMuted)
                            RiskSlider(value: $risk)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
        .background(Finora.background.ignoresSafeArea())
    }
}
