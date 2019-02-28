//
//  TipItem.swift
//  Foursquare
//
//  Created by Ramazan Öz on 28.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct TipItem: Codable {
    let tipId: String
    let tipText: String
    
    private enum CodingKeys: String, CodingKey {
        case tipId = "id"
        case tipText = "text"
    }
}
