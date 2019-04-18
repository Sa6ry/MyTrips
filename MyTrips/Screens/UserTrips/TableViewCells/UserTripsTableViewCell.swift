//
//  UserTripsTableViewCell.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/20/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class UserTripsTableViewCell: UITableViewCell {
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWith(userTrip:UserTrip) {
        self.destinationLabel.text = userTrip.destination
        switch userTrip.daysToTrip {
        case let days where days == -1:
            self.remainingDaysLabel.text = "1 day ago"
        case let days where days < 0:
            self.remainingDaysLabel.text = String(-1*days) + " days ago"
        case let days where days == 1:
            self.remainingDaysLabel.text = String(days) + " day remaining"
        case let days where days > 0:
            self.remainingDaysLabel.text = String(days) + " days remaining"
        default:
            self.remainingDaysLabel.text = "Enjoy your trip!"
        }
        self.datesLabel.text = userTrip.startDate.mediumDate + " - " + userTrip.endDate.mediumDate
    }
    
}
