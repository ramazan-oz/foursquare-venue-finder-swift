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

protocol PlacesDelegate {
    func tipsReceived(tips: Tip, photos: Photo, currentVenue: Venue)
}

class PlacesViewController: UITableViewController, MainPageDelegate {
    private var venuesArray = [Venue]()
    private var delegate: PlacesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlacesTableViewCell", bundle: nil) , forCellReuseIdentifier: "placesTableViewCell")
    }
    
    //MARK: MainPage delegate methods
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
    /// Makes an API call through foursquareAPIManager object.
    ///
    /// - parameter venue: Venue object of a place.
    private func searchVenueTipsWith(venue: Venue) {
        FoursquareAPIManager.sharedInstance.getVenueTipsWith(venueId: venue.venueId) { (result) in
            switch result {
            case let .success(tips):
                FoursquareAPIManager.sharedInstance.getPhotosWith(venueId: venue.venueId, completion: { (result) in
                    switch result {
                    case let .success(photos):
                        let tipsView = TipsView()
                        self.delegate = tipsView
                        
                        self.delegate?.tipsReceived(tips: tips, photos: photos, currentVenue: venue)
                        self.present(tipsView, animated: true)
                        SVProgressHUD.dismiss()
                    case let .failure(error):
                        guard let error = error as? FoursquareAPIManagerError else {
                            return SVProgressHUD.showError(withStatus: "Unexpected error occured")
                        }
                        
                        switch error {
                        case .unexpectedResponseError:
                            return SVProgressHUD.showError(withStatus: "Unexpected response")
                        case .connectionError(_):
                            return SVProgressHUD.showError(withStatus: "Connection error")
                        case .responseParseError(_), .apiError(_), .jsonDecodingError(_), .categoryNotFoundError, .categoryResponseEmptyError: break
                        }
                        
                        SVProgressHUD.showError(withStatus: "Failed with error")
                    }
                })
                
            case let .failure(error):
                guard let error = error as? FoursquareAPIManagerError else {
                    return SVProgressHUD.showError(withStatus: "Unexpected error occured")
                }
                
                switch error {
                case .unexpectedResponseError:
                    return SVProgressHUD.showError(withStatus: "Unexpected response")
                case .connectionError(_):
                    return SVProgressHUD.showError(withStatus: "Connection error")
                case .responseParseError(_), .apiError(_), .jsonDecodingError(_), .categoryNotFoundError, .categoryResponseEmptyError: break
                }
                
                SVProgressHUD.showError(withStatus: "Failed with error")
            }
        }
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
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchVenueTipsWith(venue: venuesArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        SVProgressHUD.show()
    }
}
