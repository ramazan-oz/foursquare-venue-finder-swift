//
//  PhotoItem.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct PhotoItem: Codable {
    let photoId: String
    let prefix: String
    let suffix: String
    
    private enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case prefix
        case suffix
    }
}
