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
                NavigationLink(destination: ChannelDetailView(viewModel: viewModel, channel: channel)) {
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

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    var placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo.circle.fill")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func load() {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }
        task.resume()
    }
}

import Foundation
import AVFoundation
import MediaPlayer

class ChannelViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var isPlaying = false
    var player: AVPlayer?
    
    private let secondsBackward: Double = 10
    private let secondsForward: Double = 10
    
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
        isPlaying = true
        setupNowPlayingInfoCenter(channel: channel)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func skipBackward() {
        let currentTime = player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)
        let newTime = CMTime(seconds: max(0, currentTime.seconds - secondsBackward), preferredTimescale: 1)
        player?.seek(to: newTime)
    }
    
    func skipForward() {
        let currentTime = player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)
        let newTime = CMTime(seconds: currentTime.seconds + secondsForward, preferredTimescale: 1)
        player?.seek(to: newTime)
    }
    
    private func setupNowPlayingInfoCenter(channel: Channel) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = channel.name ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = channel.tagline ?? ""
        if let imageUrl = channel.image, let url = URL(string: imageUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }
            task.resume()
        } else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget { event in
            self.player?.play()
            self.isPlaying = true
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
            self.player?.pause()
            self.isPlaying = false
            return .success
        }
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget { event in
            self.skipBackward()
            return .success
        }
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { event in
            self.skipForward()
            return .success
        }
    }
}
