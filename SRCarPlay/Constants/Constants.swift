//
//  Constants.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-07-12.
//

import Foundation

struct Constants {
    
    static func getUrlStringFor(path: String) -> String {
        "https://api.sr.se/api/v2/" + path + "?format=json"
    }
    
}
