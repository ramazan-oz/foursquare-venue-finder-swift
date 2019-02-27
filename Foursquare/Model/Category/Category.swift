//
//  Category.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit

struct Category: Codable {
    let categoryId: String
    let name: String
    let categories: [Category]
    
    private enum CodingKeys: String, CodingKey {
        case categoryId = "id"
        case name
        case categories
    }
}
