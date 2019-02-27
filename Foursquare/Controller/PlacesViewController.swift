//
//  PlacesViewController.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

class PlacesViewController: UITableViewController, MainPageDelegate {
    private var venuesArray = [Venue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlacesTableViewCell", bundle: nil) , forCellReuseIdentifier: "placesTableViewCell")
    }
    
    //MARK: MainPage Delegate Methods.
    func venuesReceived(venues: [Venue]) {
        self.venuesArray = venues
    }
}

extension PlacesViewController {
    /// Updates cell labels with view model data.
    ///
    /// - parameter cell: Cell to be updated.
    /// - parameter placesViewModel: Related view model object.
    private func updateCellLabel(cell: PlacesTableViewCell, placesViewModel: PlacesViewModel) {
        cell.addressLabel.text = placesViewModel.addressString
        cell.countryLabel.text = placesViewModel.countryString
        cell.placeNameLabel.text = placesViewModel.placeNameString
    }
    //MARK: - Tableview datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placesTableViewCell", for: indexPath) as! PlacesTableViewCell
        let venue = venuesArray[indexPath.row]
        let viewModel = PlacesViewModel.init(currentVenue: venue)
        
        updateCellLabel(cell: cell, placesViewModel: viewModel)
        
        return cell
    }
    //MARK: - TableView Delegate Methods.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
