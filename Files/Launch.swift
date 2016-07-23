//
//  Hero.swift
//  HoTS
//
//  Created by Joost van den Akker on 26-01-16.
//  Copyright © 2016 JoAk. All rights reserved.
//

import UIKit

class Launch {
    // MARK: Properties
    
    var launchID: Int
    var name: String
    var launchDate: String
    var successful: String
    var landing: String
    var payload: String
    var orbit: String
    var launchVehicle: String
    var launchType: String
    var launchSite: String
    var launchSpecial: String
    var youtubeFullWebcast: String
    var youtubeTechnicalWebcast: String
    var youtubeLanding: String
    var launchDescription: String

    // MARK: Initialization
    
    init?(launchID: Int, name: String, launchDate: String, successful: String, landing: String, payload: String, orbit: String, launchVehicle: String, launchType: String, launchSite: String, launchSpecial: String, youtubeFullWebcast: String, youtubeTechnicalWebcast: String, youtubeLanding: String, launchDescription: String) {
        // Initialize stored properties.
        self.launchID = launchID
        self.name = name
        self.launchDate = launchDate
        self.successful = successful
        self.landing = landing
        self.payload = payload
        self.orbit = orbit
        self.launchVehicle = launchVehicle
        self.launchType = launchType
        self.launchSite = launchSite
        self.launchSpecial = launchSpecial
        self.youtubeFullWebcast = youtubeFullWebcast
        self.youtubeTechnicalWebcast = youtubeTechnicalWebcast
        self.youtubeLanding = youtubeLanding
        self.launchDescription = launchDescription
        
        // Initialization should fail if there is no name.
        if name.isEmpty {
            return nil
        }
    }

}