//
//  FoursquareData.swift
//  Anytrail
//
//  Created by Elli Scharlin on 8/8/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class FoursquareData: NSObject {

    var placeIdentifier: String
    var placeVenue: [String : JSON]
    var placeLongitude: Double
    var placeLatitude: Double
    var placeName: String
    var placeAddress: String
    var placePhotoURL: String
    var categoryName : String

    init(json: JSON) {
        guard let
            venue = json["venue"].dictionary,
            identifier = venue["id"]!.string,
            longitude = venue["location"]!["lng"].double,
            latitude = venue["location"]!["lat"].double,
            address = venue["location"]!["formattedAddress"].array,
            name = venue["name"]!.string,
            category = venue["categories"]!.array,
            categoryDictionary = category[0].dictionary,
            categoryNameString = categoryDictionary["name"]!.string
        

            else {
                fatalError("There was an error retrieving the information from FourSquare")
        }

        var addressStringConverter = ""

        for i in 0..<address.count {
            addressStringConverter.appendContentsOf(address[i].stringValue)
        }
        categoryName = categoryNameString
        placeVenue = venue
        placeLatitude = (latitude)
        placeLongitude = (longitude)
        placeName = name
        placeAddress = addressStringConverter
        placeIdentifier = identifier
        placePhotoURL = ATConstants.Endpoints.FOURSQUARE_GET_PHOTO.stringByReplacingOccurrencesOfString("%@", withString: placeIdentifier)
    }
}
