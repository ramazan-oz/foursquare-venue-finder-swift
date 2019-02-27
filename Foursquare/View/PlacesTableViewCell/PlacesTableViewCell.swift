//
//  PlacesTableViewCell.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit

class PlacesTableViewCell: UITableViewCell {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
