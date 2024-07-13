//
//  FullPlayerView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-10.
//

import SwiftUI
import MediaPlayer

struct FullPlayerView: View {
    
    @Environment(PlayerModel.self) private var playerModel
    @Environment(\.presentationMode) private var presentationMode
    let padding: CGFloat = 5
    
    var body: some View {
        if playerModel.state != .inActive {
            VStack {
                
                dismissButton
                
                Spacer()
                
                image
                
                title
                
                description
                
                timeLine
                
                playerControls
                
                Spacer()
                
            }
            .navigationBarTitle(Text(playerModel.title ?? ""), displayMode: .inline)
        }
    }
    
    private var dismissButton: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.down.circle.fill")
                    .resizable()
                    .font(.system(size: 20))
                    .padding()
                    .frame(width: 60, height: 60)
            }
            .accessibility(label: Text("Dismiss"))
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var image: some View {
        if let imageUrl = playerModel.imageUrl {
            AsyncImage(url: imageUrl)
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fit)
        }
    }

    private var title: some View {
        Text(playerModel.title ?? "")
            .font(.largeTitle)
            .padding()
    }

    private var description: some View {
        Text(playerModel.description ?? "")
            .font(.subheadline)
            .padding()

    }
    
    @ViewBuilder
    private var timeLine: some View {
        if playerModel.state == .news {
            VStack {
                HStack {
                    Text("\(secondsToHoursMinutesSeconds(seconds: Int(playerModel.currentTime)))")
                    Spacer()
                    Text("-\(secondsToHoursMinutesSeconds(seconds: Int(playerModel.streamDuration - playerModel.currentTime)))")
                }
                
                Slider(value: playerModel.currentTimeBinding, in: 0...playerModel.streamDuration, onEditingChanged: sliderEditingChanged)
                
            }
            .padding()
            .padding(.horizontal)
        }
    }
    
    private var playerControls: some View {
        
        HStack(spacing: 0) {
            
            if playerModel.state == .news {
                
                Button(action: {
                    playerModel.player?.seek(to: .zero)
                    playerModel.player?.play()
                    playerModel.isPlaying = true
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .padding(padding)
                }
            }
            
            Button(action: {
                let cmTime = CMTime(seconds: (playerModel.player?.currentTime().seconds ?? 0) - playerModel.secondsBackward, preferredTimescale: 1)
                playerModel.player?.seek(to: cmTime)
            }) {
                ZStack {
                    Image(systemName: "gobackward")
                        .font(.system(size: 45))
                        .padding(padding)
                    Text(String(Int(playerModel.secondsBackward)))
                        .bold()
                        .offset(y: 2)
                }
            }
            
            Button(action: {
                if playerModel.isPlaying {
                    playerModel.player?.pause()
                } else {
                    playerModel.player?.play()
                }
                playerModel.isPlaying.toggle()
            }) {
                Image(systemName: playerModel.isPlaying ? "pause.circle" : "play.circle")
                    .font(.system(size: 60))
                    .padding(padding)
            }
            
            
            Button(action: {
                playerModel.player?.seek(to: CMTime(seconds: (playerModel.player?.currentTime().seconds ?? 0) + playerModel.secondsForward, preferredTimescale: 1))
            }) {
                ZStack {
                    Image(systemName: "goforward")
                        .font(.system(size: 45))
                        .padding(padding)
                    Text(String(Int(playerModel.secondsForward)))
                        .bold()
                        .offset(y: 2)
                }
            }
            if playerModel.state == .news {
                
                Button(action: {
                    playerModel.player?.seek(to: playerModel.player?.currentItem?.duration ?? .zero)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .padding(padding)
                }
            }
        }
    }

    
    private func sliderEditingChanged(editingStarted: Bool) {
        if playerModel.timeControlStatus == nil {
            playerModel.timeControlStatus = playerModel.player?.timeControlStatus
        }
        if editingStarted {
            playerModel.player?.pause()
        } else {
            playerModel.player?.seek(to: CMTime(seconds: playerModel.currentTime, preferredTimescale: 1))
            if playerModel.timeControlStatus == .playing {
                playerModel.player?.play()
            }
            playerModel.timeControlStatus = nil
        }
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (String) {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = (seconds % 3600) % 60
        return formatDuration(h: h, m: m, s: s)
    }
    
    private func formatDuration(h: Int, m: Int, s: Int) -> String {
        if m == 0 {
            return "00:" + String(format: "%02d", s)
        }
        if h == 0 {
            return String(format: "%02d:%02d", m, s)
        }
        return String(format: "%d:%02d:%02d", h, m, s)
    }
}

#Preview {
    let playerModel = PlayerModel()
    playerModel.state = .news
    playerModel.currentTime = 10
    playerModel.streamDuration = 20
    let episode = Episodes(mockID: 0)
    playerModel.initWith(episode: episode)
    return FullPlayerView()
        .environment(playerModel)
        .accentColor(.black)
}
