//
//  ATConstants.swift
//  Anytrail
//
//  Created by Ryan Cohen on 8/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ATConstants {
    
    struct Keys {
        // Key constants
    }
    
    struct Endpoints {
        static let FOURSQUARE_GET_VENUES = "https://api.foursquare.com/v2/venues/search"
        static let FOURSQUARE_GET_PHOTO = "https://api.foursquare.com/v2/venues/%@/photos?limit=1"
        static let monumentLandmarkID = "4bf58dd8d48988d12d941735"
        static let trialID = "4bf58dd8d48988d159941735"
        static let waterfrontID = "56aa371be4b08b9a8d5734c3"
        static let sculptureGardenID = "4bf58dd8d48988d166941735"
        static let scenicLookoutID = "4bf58dd8d48988d165941735"
        static let playgroundID = "4bf58dd8d48988d1e7941735"
        static let pedestrianPlaza = "52e81612bcbc57f1066b7a25"
        static let parkID = "4bf58dd8d48988d163941735"
        static let nationalParkID = "52e81612bcbc57f1066b7a21"
        static let gardenID = "4bf58dd8d48988d15a941735"
        static let bridgeID = "4bf58dd8d48988d1df941735"
        static let botanticalGardenID = "52e81612bcbc57f1066b7a22"
        static let breweryID = "50327c8591d4c4b30a586d5d"
        static let streetFairID = "5267e4d8e4b0ec79466e48c5"
        static let publicArtID = "507c8c4091d498d9fc8c67a9"
        static let museumID = "4bf58dd8d48988d181941735"
        static let historicSiteID = "4deefb944765f83613cdba6e"
    }
    
    struct Colors {
        static let RED = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.9)
        static let ORANGE = UIColor(red: 255/255, green: 157/255, blue: 76/255, alpha: 0.9)
        static let GREEN = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 0.9)
        static let BLUE = UIColor(red: 77/255, green: 122/255, blue: 255/255, alpha: 0.9)
        static let GRAY = UIColor(red: 227/255, green: 231/255, blue: 234/255, alpha: 0.9)
        static let PURPLE = UIColor(red: 74/255, green: 16/255, blue: 126/255, alpha: 0.9)
    }

}

