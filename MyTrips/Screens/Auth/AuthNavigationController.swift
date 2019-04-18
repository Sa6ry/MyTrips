//
//  LoginNavigationController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/23/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = Theme.themeBackgroundColor
        
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.themeBackgroundColor]
        
        // self.navigationBar.tintColor = UIColor.white

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
