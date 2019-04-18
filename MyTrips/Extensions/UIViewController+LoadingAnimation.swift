//
//  UIViewController+LoadingAnimation.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/28/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIViewController {

    func startLoadingAnimation(userInteractionEnabled: Bool = false) {
        self.view.isUserInteractionEnabled = userInteractionEnabled
        let activityData = ActivityData(color:UIColor.darkGray,backgroundColor:UIColor.init(white: 1.0, alpha: 0.1))
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData,nil)
    }
    
    func stopLoadingAnimation(userInteractionEnabled: Bool = true) {
        self.view.isUserInteractionEnabled = userInteractionEnabled
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
}
