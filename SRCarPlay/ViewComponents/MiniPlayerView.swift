//
//  MiniPlayerView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-11.
//

import SwiftUI

struct MiniPlayerView: View {
    
    @Environment(PlayerModel.self) var playerModel
    
    var body: some View {
        
        VStack {
            
            Divider()
            
            HStack {
                Text(playerModel.episodes?.title ?? " ")
                    .padding()
                Spacer()
                Button(action: {
                    if playerModel.isPlaying {
                        playerModel.player?.pause()
                    } else {
                        playerModel.player?.play()
                    }
                    playerModel.isPlaying.toggle()
                }) {
                    Image(systemName: playerModel.isPlaying ? "pause.circle" : "play.circle")
                        .font(.system(size: 30))
                        .padding(.horizontal)
                }
            }
            
            Divider()
            
        }
        .background(.white)
        .frame(height: 64)
        
    }
}
