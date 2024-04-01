//
//  ContentView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
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
            Text("Min sida")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Min sida")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
