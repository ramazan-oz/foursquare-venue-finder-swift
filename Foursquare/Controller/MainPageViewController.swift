//
//  MainPageViewController.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

protocol MainPageDelegate {
    func venuesReceived(venues: [Venue])
}

class MainPageViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    private let locationManager = CLLocationManager() // An object used for location related events.
    private var venuesArray = [Venue]()
    private var delegate : MainPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.distanceFilter = 20.0;
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        // If category text length is less than 3 chars.
        guard let categoryText = categoryTextField.text, categoryText.count >= 3 else {
            return SVProgressHUD.showError(withStatus: "Category must be at least 3 character long")
        }
        
        // If city text length is less than 3 chars.
        guard let cityNameText = cityTextField.text,
            cityNameText.count <= 0 || cityNameText.count >= 3 else {
            return SVProgressHUD.showError(withStatus: "City must be at least 3 character long")
        }
        
        // Search venue with city name.
        if cityNameText.count != 0 {
            SVProgressHUD.show()
            return searchVenueWith(cityName: cityNameText, category: categoryText)
        }
        // If location services is enabled.
        if !CLLocationManager.locationServicesEnabled() {
            return SVProgressHUD.showError(withStatus: "Location services is disabled. Please turn on location services from settings")
        }
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            SVProgressHUD.show()
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            if #available(iOS 10.0, *) { //If iOS 10.0 or higher.
                let alertController = UIAlertController (title: "Turn On Location Services to Allow \"Foursquare\" to Determine Your Location", message: "", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                
                alertController.addAction(alertAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                present(alertController, animated: true, completion: nil)
            } else {
                SVProgressHUD.showError(withStatus: "Location services is not allowed for the application. Please turn on location services from settings")
            }
        }
    }
    
    // MARK: - Function for a segue about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayPlaces" {
            let destination = segue.destination as! PlacesViewController
            self.delegate = destination
            delegate?.venuesReceived(venues: venuesArray)
        }
    }
    
    //MARK: - Text Field Delegate Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)
        // Allows only aplhabetic characters
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

extension MainPageViewController: CLLocationManagerDelegate {
    //MARK: - Location Manager Delegate Methods.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location : CLLocation = locations[0] as CLLocation
        
        if location.horizontalAccuracy > 0 { // If latitude and longitude of the location are valid
            manager.stopUpdatingLocation()  // Trigger didUpdateLocations...
            manager.delegate = nil          // ...only once
            let currentCoordinate = location.coordinate
            guard let categoryText = categoryTextField.text else {
                return
            }
            
            searchVenueWith(coordinate: currentCoordinate, category: categoryText)
        } else {
            SVProgressHUD.showError(withStatus: "Location unavailable")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            SVProgressHUD.show()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        case .notDetermined, .restricted, .denied:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        SVProgressHUD.showError(withStatus: "Location unavailable")
    }
    /// Makes an API call through foursquareAPIManager object.
    ///
    /// - parameter coordinate: The current coordinate.
    /// - parameter category: A category name.
    private func searchVenueWith(coordinate: CLLocationCoordinate2D, category: String) {
        FoursquareAPIManager.sharedInstance.searchVenueWith(coordinate: coordinate, categoryName: category) { (result) in
            switch result {
            case let .success(venues):
                self.venuesArray = venues
                
                if self.venuesArray.count == 0 {
                    SVProgressHUD.showError(withStatus: "No places found")
                } else {
                    self.performSegue(withIdentifier: "displayPlaces", sender: nil)
                    SVProgressHUD.dismiss()
                }
            case let .failure(error):
                guard let error = error as? FoursquareAPIManagerError else {
                    return SVProgressHUD.showError(withStatus: "Unexpected error occured")
                }
                
                switch error {
                case .unexpectedResponseError:
                    return SVProgressHUD.showError(withStatus: "Unexpected response")
                case .categoryNotFoundError:
                    return SVProgressHUD.showError(withStatus: "Category not found")
                case .categoryResponseEmptyError:
                    return SVProgressHUD.showError(withStatus: "Could not fetch categories")
                case .connectionError(_):
                    return SVProgressHUD.showError(withStatus: "Connection error")
                case .responseParseError(_), .apiError(_), .jsonDecodingError(_): break
                }
                
                SVProgressHUD.showError(withStatus: "Failed with error")
            }
        }
    }
    /// Makes an API call through foursquareAPIManager object.
    ///
    /// - parameter cityName: A city name.
    /// - parameter category: A category name.
    private func searchVenueWith(cityName: String, category: String) {
        FoursquareAPIManager.sharedInstance.searchVenueWith(cityName: cityName, categoryName: category) { (result) in
            switch result {
            case let .success(venues):
                self.venuesArray = venues
                if self.venuesArray.count == 0 {
                    SVProgressHUD.showError(withStatus: "No places found")
                } else {
                    self.performSegue(withIdentifier: "displayPlaces", sender: nil)
                    SVProgressHUD.dismiss()
                }
            case let .failure(error):
                guard let error = error as? FoursquareAPIManagerError else {
                    return SVProgressHUD.showError(withStatus: "Unexpected error occured")
                }
                
                switch error {
                case .unexpectedResponseError:
                    return SVProgressHUD.showError(withStatus: "Unexpected response")
                case .categoryNotFoundError:
                    return SVProgressHUD.showError(withStatus: "Category not found")
                case .categoryResponseEmptyError:
                    return SVProgressHUD.showError(withStatus: "Could not fetch categories")
                case .connectionError(_):
                    return SVProgressHUD.showError(withStatus: "Connection error")
                case .responseParseError(_), .apiError(_), .jsonDecodingError(_): break
                }
                
                SVProgressHUD.showError(withStatus: "Failed with error")
            }
        }
    }
}
