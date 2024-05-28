//
//  SRCarPlayTemlate.swift
//  SRCarPlay
//

import CarPlay

class SRCarPlayTemlate {
    
    var template: CPListTemplate {
        return CPListTemplate(title: "Hello world", sections: [self.section])
    }
    
    var items: [CPListItem] {
        return [CPListItem(text:"Hello world", detailText: "The world of CarPlay 7", image: UIImage(systemName: "globe"))]
    }
    
    private var section: CPListSection {
        return CPListSection(items: items)
    }
}
