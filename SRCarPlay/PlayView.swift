//
//  PlayView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-04-01.
//

import SwiftUI

struct PlayView: View {
    
    var episodes: Episodes

    var body: some View {
        Text("Hello, World!")
            .navigationBarTitle(Text(episodes.title ?? ""), displayMode: .inline)
    }
}

/*
#Preview {
    PlayView()
}
*/
