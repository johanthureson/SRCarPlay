//
//  ChannelDetailView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-06-26.
//

import SwiftUI

struct ChannelDetailView: View {
    @ObservedObject var viewModel: ChannelViewModel
    var channel: Channel
    
    var body: some View {
        VStack {
            if let imageUrl = channel.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url)
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
            }
            Text(channel.name ?? "")
                .font(.largeTitle)
                .padding()
            Text(channel.tagline ?? "")
                .font(.subheadline)
                .padding()
            HStack {
                Button(action: {
                    viewModel.skipBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 45)) // 50% bigger font size
                        .padding(10) // Increased padding
                }
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                        .font(.system(size: 45)) // 50% bigger font size
                        .padding(10) // Increased padding
                }
                Button(action: {
                    viewModel.skipForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 45)) // 50% bigger font size
                        .padding(10) // Increased padding
                }
            }
        }
        .navigationBarTitle(Text(channel.name ?? ""), displayMode: .inline)
        .onAppear {
            viewModel.playChannel(channel)
        }
    }
}
