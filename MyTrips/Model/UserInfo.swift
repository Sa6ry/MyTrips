//
//  UserInfo.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/21/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class UserInfo: NSObject, Codable {
    var email: String?
    var uid: String?
    
    init(uid: String, email: String) {
        self.email = email
        self.uid = uid
    }
}
