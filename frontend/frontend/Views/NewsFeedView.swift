import SwiftUI

// MARK: - Model (matches backend)
struct NewsFlash: Identifiable, Codable {
    var id: String
    let title: String
    let summary: String
    let source: String
    let created_at: String
    let sentiment: String
}

// MARK: - View
struct NewsFeedView: View {
    @State private var news: [NewsFlash] = []
    @State private var selectedNews: NewsFlash? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

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

                // News Highlights Section
                HStack {
                    Text("News Highlights")
                        .font(.headline)
                    Spacer()
                }
                .foregroundStyle(Finora.textPrimary)
                .padding(.horizontal)
                .padding(.top, 16)

                if isLoading {
                    ProgressView("Loading news...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("⚠️ \(errorMessage)")
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    ForEach(news) { n in
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
                                        if n.sentiment == "bullish" { Text("🚀").font(.caption) }
                                        else if n.sentiment == "bearish" { Text("📉").font(.caption) }
                                    }

                                    // Summary (2 lines)
                                    Text(n.summary)
                                        .foregroundStyle(Finora.textSecondary)
                                        .font(.footnote)
                                        .lineLimit(2)

                                    // Source / time + Read more
                                    HStack {
                                        HStack(spacing: 8) {
                                            Text(n.source)
                                                .foregroundStyle(Finora.textMuted)
                                                .font(.caption)
                                            Image(systemName: "clock")
                                                .font(.caption2)
                                                .foregroundStyle(Finora.textMuted)
                                            Text(n.created_at)
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
                }

                Spacer(minLength: 24)
            }
        }
        .background(Finora.background.ignoresSafeArea())
        .onAppear {
            fetchNews()
        }
        .sheet(item: $selectedNews) { n in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(n.title)
                        .font(.title2.bold())
                        .foregroundStyle(Finora.textPrimary)

                    HStack {
                        Text(n.source)
                        Text("•")
                        Text(n.created_at)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Finora.textMuted)

                    Text(n.summary)
                        .font(.body)
                        .foregroundStyle(Finora.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(Finora.background) // <-- requires iOS 16.4+
            .presentationDragIndicator(.visible)
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Networking
    private func fetchNews() {
        guard let url = URL(string: "http://127.0.0.1:8000/news") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load news: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode([NewsFlash].self, from: data)
                    self.news = decoded
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - Preview
struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}
