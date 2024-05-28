//
//  SRCarPlayHelloWorld.swift
//  SRCarPlay
//

import Foundation
import CarPlay

class SRCarPlayHelloWorld {
    var template: CPListTemplate {
        return CPListTemplate(title: "Hello world", sections: [self.section])
    }
    
    var items: [CPListItem] {
        return [CPListItem(text:"Hello world", detailText: "The world of CarPlay", image: UIImage(systemName: "globe"))]
    }
    
    private var section: CPListSection {
        return CPListSection(items: items)
    }
}
