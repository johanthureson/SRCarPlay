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
    
    private var state: State = .inActive
    
    private var isUp = false
    
    var episodes: Episodes?
    var channel: Channel?
    
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

    func play() {
        guard let urlString = episodes?.broadcast?.broadcastfiles?.first?.url,
              let audioURL = URL(string: urlString) else { return }
        
        player = AVPlayer(url: audioURL)
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

    
    
}

