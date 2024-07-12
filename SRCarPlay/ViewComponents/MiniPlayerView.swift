//
//  MiniPlayerView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-11.
//

import SwiftUI

struct MiniPlayerView: View {
    
    @Environment(PlayerModel.self) var playerModel
    @State private var showFullPlayer = false
    
    var body: some View {
        
        VStack {
            
            Divider()
            
            HStack {
                
                HStack {
                    Spacer()
                        .frame(width: 16)
                    Image(systemName: "chevron.up.circle.fill")
                        .resizable()
                        .font(.system(size: 20))
                        .frame(width: 30, height: 30)
                        .padding(.vertical)
                    
                    Text(playerModel.title ?? " ")
                        .padding()
                    Spacer()
                }
                // Make the entire HStack tappable
                .contentShape(Rectangle())
                .onTapGesture {
                    showFullPlayer = true // Trigger to show the modal
                }
                .fullScreenCover(isPresented: $showFullPlayer) { // 2. Use the .sheet modifier
                    FullPlayerView() // 3. Present FullPlayerView as a modal
                        .accentColor(.black)
                }
                
                // Play/Pause button
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
