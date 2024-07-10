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
    private let padding: CGFloat = 5
    
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
                    ZStack {
                        Image(systemName: "gobackward")
                            .font(.system(size: 45))
                            .padding(padding)
                        Text(String(Int(viewModel.secondsBackward)))
                            .bold()
                            .offset(y: 2)
                    }
                }
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                        .font(.system(size: 60))
                        .padding(10)
                }
                Button(action: {
                    viewModel.skipForward()
                }) {
                    ZStack {
                        Image(systemName: "goforward")
                            .font(.system(size: 45))
                            .padding(padding)
                        Text(String(Int(viewModel.secondsForward)))
                            .bold()
                            .offset(y: 2)
                    }
                }
            }
        }
        .navigationBarTitle(Text(channel.name ?? ""), displayMode: .inline)
        .onAppear {
            viewModel.playChannel(channel)
        }
    }
}
