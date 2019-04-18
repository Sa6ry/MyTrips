//
//  TripViewerProtocol.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/23/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

protocol TripViewerViewControllerDelegate: AnyObject {
    func onTripViewerUpdateTrip(_ tripViewerViewController:TripViewerViewController, updatedUserTrip:UserTrip)
}
