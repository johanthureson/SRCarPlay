//
//  PlayView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI
import AVFoundation

struct PlayView: View {
    
    var episodes: Episodes
    @State private var player: AVPlayer?

    var body: some View {
        Text("Hello, World!")
            .navigationBarTitle(Text(episodes.title ?? ""), displayMode: .inline)
            .onAppear {
                play()
            }
    }
    
    private func play() {
        guard let urlString = episodes.broadcast?.broadcastfiles?.first?.url,
              let url = URL(string: urlString) else { return }
        
        player = AVPlayer(url: url)
        player?.play()
    }
}
