//
//  PlayerModel.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-11.
//

import Foundation
import MediaPlayer

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
    var streamDuration = 0.0
    var timer: Timer? = nil
    let secondsBackward: Double = 5
    let secondsForward: Double = 30
    let padding: CGFloat = 5
    var timeControlStatus: AVPlayer.TimeControlStatus?
    
}

