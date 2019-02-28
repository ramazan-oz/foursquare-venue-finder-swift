//
//  FoursquareAPIManager.swift
//  Foursquare
//
//  Created by Ramazan Öz on 12.02.2019.
//  Copyright © 2019 Ramazan Öz. All rights reserved.
//

import UIKit
import CoreLocation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public enum FoursquareAPIManagerError: Error {
    case unexpectedResponseError
    case categoryNotFoundError
    case categoryResponseEmptyError
    case jsonDecodingError(Error)
    case connectionError(Error)
    case responseParseError(Error)
    case apiError(FoursquareAPIError)
}

public struct FoursquareAPIError: Error {
    public let errorType: String
    public let errorDetail: String
    
    init(json: Any) {
        guard let dictionary = json as? [String : Any] else {
            fatalError("Invalid json: \(json).")
        }
        
        guard let meta = dictionary["meta"] as? [String : Any] else {
            fatalError("meta section not found: \(json).")
        }
        
        guard let errorType = meta["errorType"] as? String else {
            fatalError("errorType not found: \(json).")
        }
        
        guard let errorDetail = meta["errorDetail"] as? String else {
            fatalError("errorDetail not found: \(json).")
        }
        
        self.errorType = errorType
        self.errorDetail = errorDetail
    }
}
/// Responsible for creating and managing Foursquare API calls.
class FoursquareAPIManager {
    private let APIUrl = "https://api.foursquare.com/v2"
    private let clientId = "UK42H1TGH0QB3XDI0K2ZYQCDPOMLUILBCBFTVD2BRSAO3RXZ"
    private let clientSecret = "SWPR3NS0WVMAOO0IKJGTYA4JX1XU4W5FI5BVBJJ50HVND5VY"
    private let version = "20190218"
    private let session: URLSession
    static let sharedInstance = FoursquareAPIManager()
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Accept" : "application/json",
            "Accept-language" : "*",
        ]
        
        self.session = URLSession(configuration: configuration,
                                  delegate: nil,
                                  delegateQueue: OperationQueue.main)
    }
    /// Makes an API call with the current location.
    ///
    /// - parameter coordinate: The current coordinate.
    /// - parameter categoryName: A category name.
    public func searchVenueWith(coordinate: CLLocationCoordinate2D, categoryName: String, completion: @escaping (_ result: Result<[Venue]>) -> Void) {
        getCategories { (result) in
            switch result {
            case let .success(categories):
                if categories.count <= 0 {
                    print("Category not found")
                    return completion(Result.failure(FoursquareAPIManagerError.categoryResponseEmptyError))
                }
                
                let foundCategories = self.searchCategoriesWith(categoryName: categoryName, categoriesNode: categories)
                
                if foundCategories.count <= 0 {
                    print("Cannot find category name")
                    return completion(Result.failure(FoursquareAPIManagerError.categoryNotFoundError))
                }
                
                let parameters = [
                    "ll" : "\(coordinate.latitude),\(coordinate.longitude)",
                    "category_id" : self.buildCategoryIdStringWith(categories: foundCategories),
                    "client_id" : self.clientId,
                    "client_secret" : self.clientSecret,
                    "v" :  self.version
                ]
                
                self.getJSONFrom(urlString:self.APIUrl, path: "/venues/search", parameters: parameters) { (result) in
                    switch result {
                    case let .success(data):
                        self.createResponseObjectWith(json: data, decodingModel: .venue, completion: { (result) in
                            switch result {
                            case let .success(data):
                                guard let data = data as? VenueSearchResponse else {
                                    return completion(Result.failure(FoursquareAPIManagerError.unexpectedResponseError))
                                }
                                
                                completion(Result.success(data.response.venues))
                            case let .failure(error):
                                completion(Result.failure(error))
                            }
                        })
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                }
                
            case let .failure(error):
                return completion(Result.failure(error))
            }
        }
    }
    /// Makes an API call with a city name.
    ///
    /// - parameter city: A city name.
    /// - parameter categoryName: A category name.
    public func searchVenueWith(cityName: String, categoryName: String, completion: @escaping (_ result: Result<[Venue]>) -> Void) {
        getCategories { (result) in
            switch result {
            case let .success(categories):
                if categories.count <= 0 {
                    print("Cannot not found")
                    return completion(Result.failure(FoursquareAPIManagerError.categoryResponseEmptyError))
                }
                
                let foundCategories = self.searchCategoriesWith(categoryName: categoryName, categoriesNode: categories)
                
                if foundCategories.count <= 0 {
                    print("Cannot find category name")
                    return completion(Result.failure(FoursquareAPIManagerError.categoryNotFoundError))
                }
                
                let parameters = [
                    "near" : cityName,
                    "category_id" : self.buildCategoryIdStringWith(categories: foundCategories),
                    "client_id" : self.clientId,
                    "client_secret" : self.clientSecret,
                    "v" :  self.version
                ]
                
                self.getJSONFrom(urlString:self.APIUrl, path: "/venues/search", parameters: parameters) { (result) in
                    switch result {
                    case let .success(data):
                        self.createResponseObjectWith(json: data, decodingModel: .venue, completion: { (result) in
                            switch result {
                            case let .success(data):
                                guard let data = data as? VenueSearchResponse else {
                                    return completion(Result.failure(FoursquareAPIManagerError.unexpectedResponseError))
                                }
                                
                                completion(Result.success(data.response.venues))
                            case let .failure(error):
                                completion(Result.failure(error))
                            }
                        })
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                }
                
            case let .failure(error):
                completion(Result.failure(error))
            }
        }
    }
    /// Makes an API call to get categories.
    private func getCategories(completion: @escaping (_ result: Result<[Category]>) -> Void) {
        let parameters = [
            "client_id" : self.clientId,
            "client_secret" : self.clientSecret,
            "v" :  self.version
        ]
        
        getJSONFrom(urlString:APIUrl, path: "/venues/categories", parameters: parameters) { (result) in
            switch result {
            case let .success(data):
                self.createResponseObjectWith(json: data, decodingModel: .category, completion: { (result) in
                    switch result {
                    case let .success(data):
                        guard let data = data as? CategorySearchResponse else {
                            return completion(Result.failure(FoursquareAPIManagerError.unexpectedResponseError))
                        }
                        
                        completion(Result.success(data.response.categories))
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                })
            case let .failure(error):
                completion(Result.failure(error))
            }
        }
    }
    /// Makes an API call with a venue ID.
    ///
    /// - parameter city: ID of a venue.
    public func getVenueTipsWith(venueId: String, completion: @escaping (_ result: Result<Tip>) -> Void) {
        let parameters = [
            "client_id" : self.clientId,
            "client_secret" : self.clientSecret,
            "v" :  self.version
        ]
        
        self.getJSONFrom(urlString:self.APIUrl, path: "/venues/\(venueId)/tips", parameters: parameters) { (result) in
            switch result {
            case let .success(data):
                self.createResponseObjectWith(json: data, decodingModel: .tip, completion: { (result) in
                    switch result {
                    case let .success(data):
                        guard let data = data as? TipSearchResponse else {
                            return completion(Result.failure(FoursquareAPIManagerError.unexpectedResponseError))
                        }
                        
                        completion(Result.success(data.response.tips))
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                })
            case let .failure(error):
                completion(Result.failure(error))
            }
        }
    }
    /// Makes an API call with a venue ID.
    ///
    /// - categoryName : ID of a venue.
    public func getPhotosWith(venueId: String, completion: @escaping (_ result: Result<Photo>) -> Void) {
        let parameters = [
            "client_id" : self.clientId,
            "client_secret" : self.clientSecret,
            "v" :  self.version
        ]
        
        getJSONFrom(urlString:APIUrl, path: "/venues/\(venueId)/photos", parameters: parameters) { (result) in
            switch result {
            case let .success(data):
                self.createResponseObjectWith(json: data, decodingModel: .photo, completion: { (result) in
                    switch result {
                    case let .success(data):
                        guard let data = data as? PhotoSearchResponse else {
                            return completion(Result.failure(FoursquareAPIManagerError.unexpectedResponseError))
                        }
                        
                        completion(Result.success(data.response.photos))
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                })
            case let .failure(error):
                completion(Result.failure(error))
            }
        }
    }
}

extension FoursquareAPIManager {
    //Deacoding model for response object
    public enum DecodingModel {
        case category
        case venue
        case tip
        case photo
    }
    /// Makes an HTTP GET request.
    ///
    /// - parameter urlString: URL string.
    /// - parameter parameters: Request parameters.
    private func getJSONFrom(urlString: String, path: String, parameters: [String : String], completion: @escaping (_ result: Result<Data>) -> Void) {
        let urlString = urlString + path + "?" + buildQueryStringWith(parameters: parameters)
        print("Made an HTTP request:\n\(urlString)")
        guard let url = URL(string: urlString) else {
            print("Error: Cannot create URL from string")
            return
        }
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            switch (data, response, error) {
            case (_, _, let error?):
                completion(Result.failure(FoursquareAPIManagerError.connectionError(error)))
            case (let data?, let response?, _):
                if case (200..<300)? = (response as? HTTPURLResponse)?.statusCode {
                    completion(Result.success(data))
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        completion(Result.failure(FoursquareAPIManagerError.apiError(FoursquareAPIError(json: json))))
                    } catch {
                        completion(Result.failure(FoursquareAPIManagerError.responseParseError(error)))
                    }
                }
            default:
                fatalError("invalid response combination \(data.debugDescription), \(response.debugDescription), \(error.debugDescription).")
            }
        }
        task.resume()
    }
    /// Decodes JSON data.
    ///
    /// - parameter json: JSON data.
    /// - parameter decodingModel: A decoding model.
    private func createResponseObjectWith(json: Data, decodingModel: DecodingModel, completion: @escaping (_ result: Result<Any>) -> Void) {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response: Any
            switch decodingModel {
            case .venue:
                response = try decoder.decode(VenueSearchResponse.self, from: json)
            case .category:
                response = try decoder.decode(CategorySearchResponse.self, from: json)
            case .tip:
                response = try decoder.decode(TipSearchResponse.self, from: json)
            case .photo:
                response = try decoder.decode(PhotoSearchResponse.self, from: json)
            }
            
            return completion(Result.success(response))
        } catch let error {
            print("Error creating response from JSON: \(error.localizedDescription)")
            return completion(Result.failure(FoursquareAPIManagerError.jsonDecodingError(error)))
        }
    }
    /// Builds query string for HTTP request.
    ///
    /// - parameter parameters: A dictionary of query parameters.
    private func buildQueryStringWith(parameters: [String: String]) -> String {
        var keyValPairs = [String]()
        for (key, val) in parameters {
            if let val = val.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                keyValPairs.append(key + "=" + val)
            }
        }
        return keyValPairs.joined(separator: "&")
    }
    // Builds category ID string separated with comma.
    ///
    /// - parameter foundCategories: A category array of found categories.
    private func buildCategoryIdStringWith(categories: [Category]) -> String {
        var categoryIds = [String]() // An array of category IDs
        for category in categories {
            categoryIds.append(category.categoryId)
        }
        
        return categoryIds.joined(separator: ",")
    }
    /// Searches for a category name.
    ///
    /// - parameter categoryName: A category name.
    /// - parameter categoriesNode: A category array.
    private func searchCategoriesWith(categoryName: String, categoriesNode: [Category]?) -> [Category] {
        var foundCategories = [Category]()
        // Return if no child
        guard let categoriesNode = categoriesNode else {
            return foundCategories
        }
        
        // Search a node with name 'categoryName' in the current level
        for node in categoriesNode {
            if node.name.range(of: categoryName, options: [.caseInsensitive, .diacriticInsensitive], locale: NSLocale.current) != nil {
                foundCategories.append(node)
            }
        }
        
        // Go deeper
        for node in categoriesNode {
            let found = searchCategoriesWith(categoryName: categoryName, categoriesNode: node.categories)
            foundCategories.append(contentsOf: found)
        }
        
        return foundCategories
    }
}
