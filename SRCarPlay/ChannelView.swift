//
//  ChannelView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-06-05.
//

import SwiftUI

import SwiftUI
import AVFoundation
import MediaPlayer

struct ChannelView: View {
    @ObservedObject var viewModel: ChannelViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.channels) { channel in
                NavigationLink(destination: ChannelDetailView(viewModel: viewModel, channel: channel)) {
                    HStack {
                        if let imageUrl = channel.image, let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        VStack(alignment: .leading) {
                            Text(channel.name ?? "")
                                .font(.headline)
                            Text(channel.tagline ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
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

struct ChannelDetailView: View {
    @ObservedObject var viewModel: ChannelViewModel
    var channel: Channel
    
    var body: some View {
        VStack {
            if let imageUrl = channel.image, let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            }
            Text(channel.name ?? "")
                .font(.largeTitle)
                .padding()
            Text(channel.tagline ?? "")
                .font(.subheadline)
                .padding()
            Button(action: {
                viewModel.playChannel(channel)
            }) {
                Text("Play Live Audio")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle(Text(channel.name ?? ""), displayMode: .inline)
    }
}




import Foundation
import AVFoundation

class ChannelViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    var player: AVPlayer?
    
    func loadChannels() {
        guard let url = URL(string: "https://api.sr.se/api/v2/channels?format=json") else {
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
    
    func playChannel(_ channel: Channel) {
        guard let liveAudioURLString = channel.liveaudio?.url, let liveAudioURL = URL(string: liveAudioURLString) else {
            return
        }
        player = AVPlayer(url: liveAudioURL)
        player?.play()
        setupNowPlayingInfoCenter(channel: channel)
    }
    
    private func setupNowPlayingInfoCenter(channel: Channel) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = channel.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = channel.tagline
        if let imageUrl = channel.image, let url = URL(string: imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget { event in
            self.player?.play()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
            self.player?.pause()
            return .success
        }
    }
}
