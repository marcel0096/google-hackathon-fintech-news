import SwiftUI

// MARK: - Models
struct NewsFlash: Identifiable, Codable {
    var id: String { title + source } // Simple unique id
    let title: String
    let extensive_summary: String
    let source: String
    let publication_date: String
    let sentiment: String
}

struct TwitterPost: Identifiable, Codable {
    var id: String { (author ?? "") + (created_at ?? "") + (url ?? "") }
    
    let author: String?
    let created_at: String?
    let text: String?
    let url: String?
    
    // Optional extra fields from JSON (to avoid decode crashes)
    let metric: String?
    let engagement_score: Int?
    let followers_count: Int?
    let likes: Int?
    let replies: Int?
    let reposts: Int?
}

struct NewsResponse: Codable {
    let google_feed: [NewsFlash]
    let twitter_feed: [TwitterPost]?
}

// Wrapper for selected item to use with sheet(item:)
struct SelectedItem: Identifiable {
    let id = UUID().uuidString
    let title: String
    let content: String
}

// MARK: - View
struct NewsFeedView: View {
    @State private var googleNews: [NewsFlash] = []
    @State private var twitterNews: [TwitterPost] = []
    @State private var selectedItem: SelectedItem? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @State private var showPromptInput = false
    @State private var userPrompt = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 18) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Personalized Feed!").font(.title2).bold()
                            Text("Stay informed based on your preferences")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // News Highlights
                    HStack {
                        Text("News Highlights")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    if isLoading {
                        ProgressView("Fetching news based on your interests…")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text("⚠️ \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // Google News
                        ForEach(googleNews) { n in
                            Button {
                                selectedItem = SelectedItem(title: n.title, content: n.extensive_summary)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(n.title)
                                            .font(.subheadline)
                                            .bold()
                                        if n.sentiment == "bullish" { Text("🚀").font(.caption) }
                                        else if n.sentiment == "bearish" { Text("📉").font(.caption) }
                                    }
                                    Text(n.extensive_summary)
                                        .font(.footnote)
                                        .lineLimit(2)
                                    HStack {
                                        Text(n.source)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(n.publication_date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                        
                        // Twitter News
                        if !twitterNews.isEmpty {
                            HStack {
                                Text("Twitter Posts")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            
                            ForEach(twitterNews) { t in
                                Button {
                                    selectedItem = SelectedItem(title: t.author ?? "Unknown Author", content: t.text ?? "")
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(t.author ?? "Unknown Author")
                                                .font(.subheadline)
                                                .bold()
                                        }
                                        Text(t.text ?? "")
                                            .font(.footnote)
                                            .lineLimit(2)
                                        Text(t.created_at ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    Spacer(minLength: 24)
                }
            }
            
            // Chat Icon
            Button {
                showPromptInput = true
            } label: {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 40))
                    .padding()
                    .foregroundColor(.blue)
            }
        }
        .sheet(item: $selectedItem) { item in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(item.title)
                        .font(.title2.bold())
                    Text(item.content)
                        .font(.body)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showPromptInput) {
            VStack(spacing: 16) {
                Text("Enter your prompt")
                    .font(.headline)
                TextField("Type here...", text: $userPrompt)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("Send") {
                    showPromptInput = false
                    fetchNews(with: userPrompt)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Networking
    private func fetchNews(with prompt: String = "") {
        guard let url = URL(string: "http://127.0.0.1:9000/ask_agent") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        let body: [String: String] = ["prompt": prompt]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load news: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("RAW RESPONSE:\n\(raw)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.googleNews = decoded.google_feed
                    self.twitterNews = decoded.twitter_feed ?? [] // fallback to empty
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    self.googleNews = []
                    self.twitterNews = []
                }
            }
        }.resume()
    }
}
