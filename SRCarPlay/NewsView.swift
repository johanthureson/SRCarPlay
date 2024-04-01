//
//  NewsView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI

//struct Episode: Codable, Identifiable {
//    let id: Int
//    let title: String
//}
//
//struct News: Codable {
//    let episodes: [Episode]
//}

struct NewsView: View {
    
    @State private var news = News(episodes: [])

    var body: some View {
        List(news.episodes ?? []) { episode in
            Text(episode.title ?? "")
        }
        .onAppear(perform: loadNews)
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
