//
//  TextFieldTableViewCell.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/19/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func strikText(strike: Bool) {
        if strike {
            guard self.textField.text != nil else {
                return
            }
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self.textField.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            return self.textField.attributedText = attributeString
        } else {
            guard self.textField.attributedText != nil else {
                return
            }
            self.textField.text = self.textField.attributedText?.string
        }
    }
    
}
