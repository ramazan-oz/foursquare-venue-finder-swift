//
//  TipsView.swift
//  Foursquare
//
//  Created by Ramazan Öz on 28.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class TipsView: UIViewController, PlacesDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate {
    @IBOutlet weak var venueLocationMap: MKMapView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var tipsView: UIView!
    
    private var venue: Venue?
    private var tips: Tip?
    private var photos: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotationToMap()
        displayTips()
        displayPhotos()
    }
    
    // MARK: Background tap gesture method
    @IBAction func backgroudViewTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Gesture recognizer delegate methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Touches on backgroundView only
        return touch.view == backgroundView
    }
    
    // MARK: Places delegate methods
    func tipsReceived(tips: Tip, photos: Photo, currentVenue: Venue) {
        self.tips = tips
        self.photos = photos
        self.venue = currentVenue
    }
    
    // Displays current venue data
    private func addAnnotationToMap() {
        guard let venue = venue else {
            return
        }
        // Add annotation to the mapview with the current location
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate.latitude = venue.location.latitude
        pointAnnotation.coordinate.longitude = venue.location.longitude
        pointAnnotation.title = venue.name
        DispatchQueue.main.async {
            self.venueLocationMap.addAnnotation(pointAnnotation)
        }
        // Zoom in on the annotation
        let region = MKCoordinateRegion(center: pointAnnotation.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        DispatchQueue.main.async {
            self.venueLocationMap.setRegion(region, animated: true)
            self.venueLocationMap.showsUserLocation = true
            self.venueNameLabel.text = venue.name
        }
    }
    /// Displays all images as scrollable slides.
    private func displayPhotos() {
        guard let photoItems = photos?.items else {
            return
        }
        
        var slides = [Slide]()
        for i in 0..<photoItems.count {
            let photoUrl = photoItems[i].prefix + "500x500" + photoItems[i].suffix
            let slide: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide.imageView.downloadImageWith(urlString: photoUrl)
            slides.append(slide)
        }
        
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width * CGFloat(slides.count), height: imageScrollView.frame.height)
        imageScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: imageScrollView.frame.width * CGFloat(i), y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
            imageScrollView.addSubview(slides[i])
        }
    }
    /// Creates labels of tips and dividers between.
    private func displayTips() {
        guard let tipItems = tips?.items, tipItems.count > 0 else {
            DispatchQueue.main.async {
                self.tipsLabel.isHidden = true
            }
            
            return
        }
        
        var label: UILabel
        var divider: UIView
        var y: CGFloat = 12 // Starting value for y coordinate
        for i in 0..<tipItems.count {
            label = UILabel(frame: CGRect(x: 12, y: y, width: tipsView.frame.size.width - 24, height: 0))
            label.textColor = UIColor.black
            label.font = UIFont(name: "SFUIText-Regular", size: 14)
            label.numberOfLines = 0
            label.text = tipItems[i].tipText
            label.sizeToFit()
            tipsView.addSubview(label)
            
            if i == tipItems.count - 1 { // If this is the last iteration skip adding new divider
                y = label.frame.origin.y + label.frame.height + 12 // set the new subview's y coordinate
            } else {
                divider = UIView(frame: CGRect(x: 12, y: label.frame.origin.y + label.frame.height + 12, width: tipsView.frame.size.width - 24, height: 1))
                divider.layer.borderWidth = 1.0
                divider.layer.borderColor = UIColor.black.cgColor
                tipsView.addSubview(divider)
                y = divider.frame.origin.y + divider.frame.height + 12// set the new subview's y coordinate
            }
        }
        // Calculate constant with new height
        let neededContentHeight = self.bottomContainer.frame.origin.y + tipsView.frame.origin.y + y
        let contentViewHeight = self.contentView.frame.height
        // Stretch contentView if new needed height is greater than contentView's
        if neededContentHeight > contentViewHeight {
            stretchContentView(constant: neededContentHeight - contentViewHeight)
        }
    }
    /// Stretches containerView with new constant value.
    ///
    /// - parameter constant: Constant value for contentViewHeightConstraint.
    private func stretchContentView(constant: CGFloat) {DispatchQueue.main.async {
        // Strech content view with the content size of tableview
        self.contentViewHeightConstraint.constant = constant
        self.contentView.layoutIfNeeded()
        // Set scrollview contentsize to contentview's frame size
        self.scrollView.contentSize = self.contentView.frame.size
        }
    }
}
extension UIImageView {
    /// Downloads image and set UIImageView with it.
    ///
    /// - parameter urlString: A URL string of an image to be downloaded.
    func downloadImageWith(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
        request.httpShouldHandleCookies = false
        request.httpShouldUsePipelining = true
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.contentMode = .scaleAspectFit
                self.image = image
            }
            }.resume()
    }
}
