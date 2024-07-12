//
//  ContentView.swift
//  SRCarPlay
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: Int = UserDefaults.standard.integer(forKey: "selectedTab")
    @Environment(PlayerModel.self) var playerModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NewsView()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Nyheter")
                    }
                    .tag(0)
                ChannelView()
                    .tabItem {
                        Image(systemName: "radio.fill")
                        Text("Kanaler")
                    }
                    .tag(1)
            }
            .onAppear {
                // Read the last selected tab from UserDefaults when the view appears
                selectedTab = UserDefaults.standard.integer(forKey: "selectedTab")
            }
            .onChange(of: selectedTab) { _, newValue in
                // Save the newly selected tab to UserDefaults
                UserDefaults.standard.set(newValue, forKey: "selectedTab")
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
