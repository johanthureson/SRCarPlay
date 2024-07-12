//
//  MiniPlayerFooterSpaceView.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-12.
//

import SwiftUI

struct MiniPlayerFooterSpaceView: View {

    @Environment(PlayerModel.self) var playerModel

    var body: some View {
        
        if playerModel.state != .inActive {
            Spacer()
                .frame(height: 64)
                .background(Color.clear)
        }
        
    }
}

