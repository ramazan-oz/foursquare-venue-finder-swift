//
//  Photo.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let count: Double
    let items: [PhotoItem]
}
