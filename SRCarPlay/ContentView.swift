//
//  ContentView.swift
//  SRCarPlay
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NewsView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Nyheter")
                }
                .tag(0)
            Text("Kanaler")
                .tabItem {
                    Image(systemName: "radio.fill")
                    Text("Kanaler")
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
