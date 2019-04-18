//
//  UIViewController+Error.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/25/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

extension UIViewController {

    func showMessageBox(title:String? = nil, message: String? = nil) {
        let completedAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        completedAlert.addAction(ok)
        self.present(completedAlert, animated: true)
    }

}
