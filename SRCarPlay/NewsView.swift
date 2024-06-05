//
//  NewsView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI

struct NewsView: View {
    @State private var news = News(episodes: [])

    var body: some View {
        NavigationView {
            List(news.episodes ?? []) { episode in
                NavigationLink(destination: PlayView(episodes: episode)) {
                    HStack {
                        if let imageUrl = episode.imageurl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Text(episode.title ?? "")
                            .frame(height: 44)
                    }
                }
            }
            .onAppear(perform: loadNews)
            .navigationBarTitle("Nyheter", displayMode: .inline)
        }
    }

    func loadNews() {
        guard let url = URL(string: "https://api.sr.se/api/v2/news/episodes?format=json") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(News.self, from: data) {
                    DispatchQueue.main.async {
                        self.news = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

#Preview {
    NewsView()
}
