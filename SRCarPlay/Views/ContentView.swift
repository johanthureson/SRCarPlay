//
//  ContentView.swift
//  SRCarPlay
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    @Environment(PlayerModel.self) var playerModel
    let channelViewModel = ChannelViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NewsView()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Nyheter")
                    }
                    .tag(0)
                ChannelView(viewModel: channelViewModel)
                    .tabItem {
                        Image(systemName: "radio.fill")
                        Text("Kanaler")
                    }
                    .tag(1)
            }
            
            if playerModel.state != .inActive {
                MiniPlayerView()
                    .offset(y: -53) // Adjust the offset if needed based on the TabBar's height
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
