//
//  SRCarPlayApp.swift
//  SRCarPlay
//

import SwiftUI

@main
struct SRCarPlayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(PlayerModel())
                .accentColor(.black)
        }
    }
}
