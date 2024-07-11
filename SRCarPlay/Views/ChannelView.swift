//
//  ChannelView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-06-05.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct ChannelView: View {
    @ObservedObject var viewModel: ChannelViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.channels) { channel in
                NavigationLink(destination: ChannelPlayView(viewModel: viewModel, channel: channel)) {
                    HStack {
                        if let imageUrl = channel.image, let url = URL(string: imageUrl) {
                            AsyncImage(url: url)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Spacer()
                            .frame(width: 16)
                        VStack(alignment: .leading) {
                            Text(channel.name ?? "")
                                .font(.headline)
                            Text(channel.tagline ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .navigationBarTitle("Kanaler")
        }
        .onAppear {
            viewModel.loadChannels()
        }
    }
}

