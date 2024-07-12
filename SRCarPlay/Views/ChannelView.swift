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
    @Environment(PlayerModel.self) var playerModel
    
    var body: some View {
        
        List {
            Section {
                ForEach(viewModel.channels, id: \.self) { channel in
                    Button(action: {
                        self.playerModel.state = .channel
                        self.playerModel.initWith(channel: channel)
                        self.playerModel.play()
                    }) {
                        HStack {
                            if let imageUrl = channel.image, let url = URL(string: imageUrl) {
                                AsyncImage(url: url)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Spacer().frame(width: 16)
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
                
            } footer: {
                if playerModel.state != .inActive {
                    Spacer()
                        .frame(height: 64)
                        .background(Color.clear)
                }
            }
        }
        .navigationBarTitle("Kanaler", displayMode: .inline)
        
        .onAppear {
            viewModel.loadChannels()
        }
        
    }
}

