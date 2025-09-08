import SwiftUI

// MARK: - Model
struct NewsFlash: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let time: String
    let trending: Bool
    let content: String
}

struct AssetSummary: Identifiable {
    let id = UUID()
    let category: String
    let up: Int
    let down: Int
    let total: Int
}

// MARK: - Mock data
let mockNews: [NewsFlash] = [
    .init(
        title: "Fed Announces Rate Cut",
        summary: "Markets react positively to monetary policy easing.",
        source: "Reuters",
        time: "1h ago",
        trending: true,
        content:
            "Full article content goes here. The Federal Reserve has signaled a potential rate cut..."
    ),
    .init(
        title: "Tesla Q3 Deliveries Beat Expectations",
        summary: "EV manufacturer exceeds forecasted numbers.",
        source: "Bloomberg",
        time: "2h ago",
        trending: false,
        content:
            "Tesla reports record deliveries in Q3 despite supply chain challenges..."
    ),
    .init(
        title: "Oil Prices Surge",
        summary: "Geopolitical tensions push Brent crude higher.",
        source: "Financial Times",
        time: "3h ago",
        trending: false,
        content:
            "Oil prices rise sharply due to Middle East tensions and OPEC+ production cuts..."
    ),
    .init(
        title: "NVIDIA Reports Record Revenue",
        summary: "AI chip demand drives massive growth.",
        source: "TechCrunch",
        time: "4h ago",
        trending: true,
        content:
            "NVIDIA's AI chip sales have skyrocketed, driving record quarterly revenue..."
    ),
]

// MARK: - NewsFeedView
struct NewsFeedView: View {
    @State private var selectedNews: NewsFlash? = nil

    let assets: [AssetSummary] = [
        .init(category: "Stocks", up: 124, down: 87, total: 350),
        .init(category: "Crypto", up: 45, down: 12, total: 90),
        .init(category: "ETFs", up: 23, down: 30, total: 110),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalized Feed!").font(.title2).bold()
                            .foregroundStyle(Finora.textPrimary)
                        Text("Stay informed based on your preferences")
                            .foregroundStyle(Finora.textMuted)
                    }
                    Spacer()
                    Image(systemName: "ellipsis").foregroundStyle(
                        Finora.textSecondary)
                }
                .padding(.horizontal)

                // Market Overview cards
                VStack(spacing: 12) {
                    HStack {
                        Text("Market Overview").font(.headline)
                        Spacer()
                        //Image(systemName: "chevron.right")
                    }.foregroundStyle(Finora.textPrimary)
                    LazyVGrid(
                        columns: Array(
                            repeating: .init(.flexible(), spacing: 12), count: 3
                        ), spacing: 12
                    ) {
                        ForEach(assets) { item in
                            GlassCard {
                                Text(item.category).font(.subheadline)
                                    .fontWeight(.semibold)
                                HStack(spacing: 8) {
                                    Label(
                                        "\(item.up)",
                                        systemImage: "arrow.up.right"
                                    )
                                    .foregroundStyle(Finora.success).font(
                                        .caption)
                                    Label(
                                        "\(item.down)",
                                        systemImage: "arrow.down.right"
                                    )
                                    .foregroundStyle(Finora.danger).font(
                                        .caption)
                                }
                                Text("\(item.total) assets").font(.caption)
                                    .foregroundStyle(Finora.textMuted)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                HStack {
                    Text("News Highlights")
                        .font(.headline)
                    Spacer()
                }
                .foregroundStyle(Finora.textPrimary)
                .padding(.horizontal)
                .padding(.top, 16)

                ForEach(mockNews) { n in
                    Button {
                        selectedNews = n
                    } label: {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                // Title + trending emoji
                                HStack {
                                    Text(n.title)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(Finora.textPrimary)
                                    if n.trending { Text("🚀").font(.caption) }
                                }

                                // Summary
                                Text(n.summary)
                                    .foregroundStyle(Finora.textSecondary)
                                    .font(.footnote)

                                // Source / time + Read more
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
                                    Text("Read more")
                                        .font(.caption)
                                        .foregroundStyle(Finora.primary)
                                }
                            }
                            .padding(12)
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 24)
            }
        }
        .background(Finora.background.ignoresSafeArea())
        .sheet(item: $selectedNews) { n in
            VStack(spacing: 12) {
                Capsule()
                    .fill(Finora.textMuted)
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(n.title)
                            .font(.title2.bold())
                            .foregroundStyle(Finora.textPrimary)

                        HStack {
                            Text(n.source)
                            Text("•")
                            Text(n.time)
                        }
                        .font(.subheadline)
                        .foregroundStyle(Finora.textMuted)

                        Text(n.content)
                            .font(.body)
                            .foregroundStyle(Finora.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Preview
struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}
