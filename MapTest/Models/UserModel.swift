//
//  UseViewModel.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 29.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import GooglePlaces


struct UserModel: Codable {
    let userID:     String
    let name:       String
    var coordinate: CLLocationCoordinate2D?
    var lastUpdate: NSDate?
    var isOnline:   Bool {
        get {
            guard let interval = lastUpdate?.timeIntervalSinceReferenceDate else {return false}
            return (NSDate().timeIntervalSinceReferenceDate - interval) < 4
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case userID     = "userID"
        case name       = "name"
        case coordinate = "coordinate"
        case lastUpdate = "lastUpdate"
    }
    
    init(from decoder: Decoder) throws {
        do {
        let values = try decoder.container(keyedBy: CodingKeys.self)
            userID = try values.decode(String.self, forKey: .userID)
            name   = try values.decode(String.self, forKey: .name)
            coordinate = try values.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .coordinate)
            
            var lastUpdateValue: NSDate?
            if let timeIntervalSinceReferenceDate = try values.decodeIfPresent(Double.self, forKey: .lastUpdate) {
                lastUpdateValue = NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
            } else {
                lastUpdateValue = nil
            }
            lastUpdate = lastUpdateValue
            
        } catch let error {
            throw error
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(coordinate, forKey: .coordinate)
        try container.encodeIfPresent(lastUpdate?.timeIntervalSinceReferenceDate, forKey: .lastUpdate)
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude  = "latitude"
        case longitude = "longitude"
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            latitude  = try values.decode(Double.self, forKey: .latitude)
            longitude = try values.decode(Double.self, forKey: .longitude)
        } catch let error {
            throw error
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

