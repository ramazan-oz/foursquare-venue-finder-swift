//
//  Venue.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit

struct Venue: Codable {
    let venueId: String
    let name: String
    let location: Location
    
    private enum CodingKeys: String, CodingKey {
        case venueId = "id"
        case name
        case location
    }
}
