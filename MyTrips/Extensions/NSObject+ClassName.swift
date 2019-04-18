//
//  NSObject+ClassName.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/18/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}

