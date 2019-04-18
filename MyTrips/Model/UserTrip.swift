//
//  UserTrip.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/19/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class UserTrip: NSObject, NSCopying, Codable {
    
    var destination: String
    var startDate: Date
    var endDate: Date
    var comment: String
    var uuid: String
        
    override convenience init() {
        self.init(destination: "", startDate: Date(), endDate: Date(), comment: "", uuid: UUID().uuidString)
    }
    
    init(destination: String, startDate: Date, endDate: Date, comment: String, uuid: String) {
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.comment = comment
        self.uuid = uuid
    }
    
    func copyValues(_ userTrip:UserTrip) {
        self.destination = userTrip.destination
        self.startDate = userTrip.startDate
        self.endDate = userTrip.endDate
        self.comment = userTrip.comment
        self.uuid = userTrip.uuid
    }

    
    var daysToTrip: Int {
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let dateStart = calendar.startOfDay(for: startDate)
        let dateEnd = calendar.startOfDay(for: endDate)
        let dateNow = calendar.startOfDay(for: Date())
        if dateNow < dateStart {
            return calendar.dateComponents([.day], from: dateNow, to: dateStart).day!
        } else if dateNow > dateEnd {
            let days = calendar.dateComponents([.day], from: dateNow, to: dateEnd).day!
            return days
        } else {
            return 0
        }
    }
    
    var tripDurationInDays: Int {
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day!
    }
    
    var isValidEndDate: Bool {
        return self.tripDurationInDays >= 0
    }
    
    func contains(_ text:String) -> Bool {
        let searchText = text.lowercased()
        return self.comment.lowercased().contains(searchText) || self.destination.lowercased().contains(searchText) || self.startDate.fullDate.lowercased().contains(searchText) || self.endDate.fullDate.lowercased().contains(searchText)
    }
    
    class var empty: UserTrip {
        return UserTrip()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let comparingObject = object as? UserTrip else {
            return false
        }
        return self.destination == comparingObject.destination &&
            self.startDate == comparingObject.startDate &&
            self.endDate == comparingObject.endDate &&
            self.comment == comparingObject.comment &&
        self.uuid == comparingObject.uuid
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = UserTrip(destination: destination, startDate: startDate, endDate: endDate, comment: comment, uuid: uuid)
        return copy
    }
}
