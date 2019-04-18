//
//  NSDate+Formates.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/19/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

extension Date {
    private func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                              in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    var fullDate:  String { return localizedDescription(dateStyle: .full, timeStyle: .none)  }
    var mediumDate:  String { return localizedDescription(dateStyle: .medium, timeStyle: .none)  }
    var shortDate: String { return localizedDescription(dateStyle: .short, timeStyle: .none)  }
    var fullTime:  String { return localizedDescription(dateStyle: .none, timeStyle: .full)  }
    var shortTime: String { return localizedDescription(dateStyle: .none, timeStyle: .short)   }
    var fullDateTime:  String { return localizedDescription(dateStyle: .full, timeStyle: .full)  }
    var shortDateTime: String { return localizedDescription(dateStyle: .short, timeStyle: .short)  }
}
