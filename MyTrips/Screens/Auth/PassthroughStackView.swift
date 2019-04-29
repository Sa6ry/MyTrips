//
//  PassthroughStackView.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/29/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class PassthroughStackView: UIStackView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
}
