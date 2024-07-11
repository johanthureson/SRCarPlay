//
//  ChannelViewModel.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-06-26.
//

import Foundation
import AVFoundation
import MediaPlayer

class ChannelViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var isPlaying = false
    var player: AVPlayer?
    
    let secondsBackward: Double = 5
    let secondsForward: Double = 30
    
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
