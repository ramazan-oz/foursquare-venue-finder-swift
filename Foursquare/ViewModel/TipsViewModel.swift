//
//  TipsViewModel.swift
//  Foursquare
//
//  Created by Ramazan Öz on 28.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import Foundation

struct TipsViewModel {
    private let currentTip: TipItem
    private(set) var tipText = ""
    
    public init(currentTip: TipItem) {
        self.currentTip = currentTip
        
        UpdateProperties()
    }
    
    private mutating func UpdateProperties() {
        tipText = currentTip.tipText
    }
}
