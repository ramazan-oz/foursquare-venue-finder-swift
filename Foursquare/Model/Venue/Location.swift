//
//  Location.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit

struct Location: Codable {
    let address: String?
    let latitude: Double
    let longitude: Double
    let country: String
    let formattedAddress: [String]
    
    private enum CodingKeys: String, CodingKey {
        case address
        case latitude = "lat"
        case longitude = "lng"
        case country
        case formattedAddress
    }
}
