//
//  PlayerModel.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-11.
//

import Foundation
import MediaPlayer
import SwiftUI

@Observable class PlayerModel {
    
    enum State {
        case inActive
        case news
        case channel
    }
    
    var state: State = .inActive
    
    private var isUp = false
    
    var imageUrl: URL?
    var title: String?
    var description: String?
    var audioUrlString: String?
    private var lastAudioUrlString: String?
    
    var player: AVPlayer?
    var isPlaying = false
    
    
    var currentTime = 0.0
    
    var currentTimeBinding: Binding<Double> {
        Binding(
            get: { self.currentTime },
            set: { self.currentTime = $0 }
        )
    }
    
    var streamDuration = 0.0
    var timer: Timer? = nil
    let secondsBackward: Double = 5
    let secondsForward: Double = 30
    let padding: CGFloat = 5
    var timeControlStatus: AVPlayer.TimeControlStatus?
    
    func initWith(episode: Episodes) {
        if let imageUrlString = episode.imageurl {
            imageUrl = URL(string: imageUrlString)
        }
        title = episode.title
        description = episode.description
        audioUrlString = episode.broadcast?.broadcastfiles?.first?.url
        state = .news
    }
    
    func initWith(channel: Channel) {
        if let imageUrlString = channel.image {
            imageUrl = URL(string: imageUrlString)
        }
        title = channel.name
        description = channel.tagline
        audioUrlString = channel.liveaudio?.url
        state = .channel
    }
    
    
    func play() {
        
        configureAudioSession()

        guard let audioUrlString,
              let audioURL = URL(string: audioUrlString)
        else { return }
        // Only restart player if episode changed
        if audioUrlString != lastAudioUrlString {
            player = AVPlayer(url: audioURL)
            lastAudioUrlString = audioUrlString
        }
        
        player?.play()
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentTime = self.player?.currentTime().seconds ?? 0
            guard let seconds = self.player?.currentItem?.duration.seconds else {
                self.streamDuration = 0
                return
            }
            if seconds.isNaN {
                self.streamDuration = 0
            } else {
                self.streamDuration = seconds
            }
        }
        
    }
    
    // Configure the audio session
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
    }
    
}
