//
//  MiniPlayerView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-11.
//

import SwiftUI

struct MiniPlayerView: View {
    
    @Environment(PlayerModel.self) private var playerModel
    @State private var showFullPlayer = false
    
    var body: some View {
        
        VStack {
            
            Divider()
            
            HStack {
                
                HStack {
                    
                    upArrow

                    title
                    
                }
                // Make the entire HStack tappable
                .contentShape(Rectangle())
                
                .onTapGesture {
                    showFullPlayer = true // Trigger to show the modal
                }
                
                .fullScreenCover(isPresented: $showFullPlayer) {
                    FullPlayerView()
                        .accentColor(.black)
                }
                
                playPauseButton
                
            }
            
            Divider()
            
        }
        .background(.white)
        .frame(height: 64)
        
    }
    
    @ViewBuilder
    private var upArrow: some View {
        Spacer()
            .frame(width: 16)
        Image(systemName: "chevron.up.circle.fill")
            .resizable()
            .font(.system(size: 20))
            .frame(width: 30, height: 30)
            .padding(.vertical)
    }
    
    @ViewBuilder
    private var title: some View {
        Text(playerModel.title ?? " ")
            .padding()
        Spacer()
    }
    
    private var playPauseButton: some View {
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
    
}
