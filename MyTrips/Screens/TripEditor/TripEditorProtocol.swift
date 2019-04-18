//
//  TripEditorProtocol.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/20/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

protocol TripEditorViewControllerDelegate: AnyObject {
    func onTripEditorAddTrip(_ tripEditorViewController:TripEditorViewController, newUserTrip:UserTrip)
    func onTripEditorUpdateTrip(_ tripEditorViewController:TripEditorViewController, updatedUserTrip:UserTrip)
}
