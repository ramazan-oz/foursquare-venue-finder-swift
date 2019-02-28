//
//  Tip.swift
//  Foursquare
//
//  Created by Ramazan Öz on 28.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct Tip: Codable {
    let count: Double
    let items: [TipItem]
}
