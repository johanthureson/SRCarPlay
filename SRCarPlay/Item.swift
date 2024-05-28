//
//  Item.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-05-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
