//
//  ContentView.swift
//  SRCarPlay
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Poddar")
                .tabItem {
                    Image(systemName: "headphones")
                    Text("Poddar")
                }
                .tag(0)
            NewsView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Nyheter")
                }
                .tag(1)
            Text("Kanaler")
                .tabItem {
                    Image(systemName: "radio.fill")
                    Text("Kanaler")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
