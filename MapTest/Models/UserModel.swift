//
//  UseViewModel.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 29.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import RxSwift
import GooglePlaces

struct UserModel: Codable {
    let userID:     Variable<String>
    let name:       Variable<String>
    var coordinate: Variable<CLLocationCoordinate2D?>
    var lastUpdate: Variable<NSDate?>
    var isOnline:   Observable<Bool> 
    
    enum CodingKeys: String, CodingKey {
        case userID     = "userID"
        case name       = "name"
        case coordinate = "coordinate"
        case lastUpdate = "lastUpdate"
    }
    
    init(from decoder: Decoder) throws {
        do {
        let values = try decoder.container(keyedBy: CodingKeys.self)
            let userIDValue = try values.decode(String.self, forKey: .userID)
            userID = Variable<String>.init(userIDValue)
            let nameValue   = try values.decode(String.self, forKey: .name)
            name   = Variable<String>.init(nameValue)
            let coordinateValue = try values.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .coordinate)
            coordinate = Variable<CLLocationCoordinate2D?>.init(coordinateValue)
            var lastUpdateValue: NSDate?
            if let timeIntervalSinceReferenceDate = try values.decodeIfPresent(Double.self, forKey: .lastUpdate) {
                lastUpdateValue = NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
            } else {
                lastUpdateValue = nil
            }
            lastUpdate = Variable<NSDate?>.init(lastUpdateValue)
            
            let timer = Observable<NSInteger>.interval(90, scheduler: MainScheduler.instance)
            isOnline = Observable<Bool>.combineLatest(self.lastUpdate.asObservable(), timer)
            { (lastUpdate, timer) in
                guard let interval = lastUpdate?.timeIntervalSinceReferenceDate else {return false}
                return (NSDate().timeIntervalSinceReferenceDate - interval) > 90
            }
        } catch let error {
            throw error
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID.value, forKey: .userID)
        try container.encode(name.value, forKey: .name)
        try container.encodeIfPresent(coordinate.value, forKey: .coordinate)
        try container.encodeIfPresent(lastUpdate.value?.timeIntervalSinceReferenceDate, forKey: .lastUpdate)
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

