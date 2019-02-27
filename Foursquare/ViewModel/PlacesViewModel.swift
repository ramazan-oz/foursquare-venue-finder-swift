//
//  PlacesViewModel.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct PlacesViewModel {
    private let currentVenue: Venue
    private(set) var placeNameString = ""
    private(set) var addressString = ""
    private(set) var countryString = ""
    
    public init(currentVenue: Venue) {
        self.currentVenue = currentVenue
        updateProperties()
    }
    
    private mutating func updateProperties() {
        placeNameString = currentVenue.name
        addressString = currentVenue.location.address ?? currentVenue.location.formattedAddress.joined(separator: "\n")
        countryString = currentVenue.location.country
    }
}
