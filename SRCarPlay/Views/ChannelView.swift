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
    
    @State private var channels: [Channel] = []
    @Environment(PlayerModel.self) var playerModel
    
    var body: some View {
        
        List {
            Section {
                ForEach(channels, id: \.self) { channel in
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
            loadChannels()
        }
        
    }
    
    private func loadChannels() {
        guard let url = URL(string: Constants.getUrlStringFor(path: "channels")) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(ChannelsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.channels = decodedResponse.channels
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }

}

