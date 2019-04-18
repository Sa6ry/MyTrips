//
//  UserTripsViewController+Search.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/27/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

extension UserTripsViewController {
    func filterUserTrips(userTrips:[UserTrip], searchText: String, completion: @escaping (_ filteredUserTrips:[UserTrip], _ searchText:String, _ error:String?) -> Void) {
        // TODO: filtering should be done on the serverside
        // For now, we are going to simulate network calls
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.2...1.0), execute: {
            let filteredTrips = userTrips.filter { $0.contains(searchText) }
            completion(filteredTrips, searchText, nil)
        })
    }
}
