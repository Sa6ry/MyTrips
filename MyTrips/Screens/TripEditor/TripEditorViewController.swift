//
//  UserTripViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/19/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

private extension IndexPath {
    static var destination: IndexPath { return IndexPath(row: 0, section: 0) }
    static var startDate: IndexPath { return IndexPath(row: 0, section: 1) }
    static var startDatePicker: IndexPath { return IndexPath(row: 1, section: 1) }
    static var endDate: IndexPath { return IndexPath(row: 0, section: 2) }
    static var endDatePicker: IndexPath { return IndexPath(row: 1, section: 2) }
    static var comment: IndexPath { return IndexPath(row: 0, section: 3) }
}

class TripEditorViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    
    class func navigationViewControllerInstance(userTrip: UserTrip? = nil, tripEditorDelegate: TripEditorViewControllerDelegate) -> UINavigationController {
        let storyboard : UIStoryboard = UIStoryboard(name: "TripEditor", bundle: nil)
        let nv = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nv.viewControllers.first as! TripEditorViewController
        vc.initialUserTrip = userTrip ?? UserTrip.empty
        vc.currentUserTrip = vc.initialUserTrip.copy() as? UserTrip
        vc.tripEditorDelegate = tripEditorDelegate
        vc.isNewTrip = userTrip == nil
        return nv
    }
    
    // MARK: - Properties
    var startDatePickerShown:Bool = false
    var endDatePickerShown:Bool = false
    var isNewTrip:Bool = false
    
    var initialUserTrip: UserTrip!
    var currentUserTrip: UserTrip!
    var tripEditorDelegate: TripEditorViewControllerDelegate!
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        self.tableView.estimatedRowHeight = 500
        self.title = self.isNewTrip ? "Add Trip" : "Edit Trip"
        self.tableView.register(UINib(nibName: TextFieldTableViewCell.className, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.className)
        self.tableView.register(UINib(nibName: DatePickerTableViewCell.className, bundle: nil), forCellReuseIdentifier: DatePickerTableViewCell.className)
        self.tableView.register(UINib(nibName: TextViewTableViewCell.className, bundle: nil), forCellReuseIdentifier: TextViewTableViewCell.className)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation buttons
    
    @IBAction func onCancel(_ sender: Any) {
        self.hideKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        if self.description.count == 0 {
            
        }
        self.hideKeyboard()
        if self.isNewTrip {
            self.tripEditorDelegate.onTripEditorAddTrip(self, newUserTrip: self.currentUserTrip)
        } else {
            self.tripEditorDelegate.onTripEditorUpdateTrip(self, updatedUserTrip: self.currentUserTrip)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view delegates & datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case IndexPath.startDate.section:
            return self.startDatePickerShown ? 2 : 1
        case IndexPath.endDate.section:
            return self.endDatePickerShown ? 2 : 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case IndexPath.destination.section:
            return "Destination"
        case IndexPath.startDate.section:
            return "Start Date"
        case IndexPath.endDate.section:
            return "End Date"
        case IndexPath.comment.section:
            return "Comment"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case IndexPath.startDate,
             IndexPath.endDate,
             IndexPath.destination:
            return 50
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case IndexPath.startDate,
             IndexPath.endDate,
             IndexPath.destination:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.className, for: indexPath) as! TextFieldTableViewCell
            switch indexPath {
            case IndexPath.destination:
                cell.textField.text = self.currentUserTrip.destination
                cell.textField.delegate = self
                cell.textField.isUserInteractionEnabled = true
            case IndexPath.startDate:
                cell.textField.text = self.currentUserTrip.startDate.fullDate
                cell.textField.isUserInteractionEnabled = false
                cell.textField.delegate = nil
            case IndexPath.endDate:
                cell.textField.text = self.currentUserTrip.endDate.fullDate
                cell.strikText(strike: self.currentUserTrip.isValidEndDate == false)
                cell.textField.isUserInteractionEnabled = false
                cell.textField.delegate = nil
            default:
                break
            }
            return cell
        case IndexPath.startDatePicker,
             IndexPath.endDatePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.className, for: indexPath) as! DatePickerTableViewCell
            cell.datePicker.removeTarget(self, action: #selector(onEndDateChage), for: .valueChanged);
            cell.datePicker.removeTarget(self, action: #selector(onStartDateChange), for: .valueChanged);
            if indexPath == IndexPath.startDatePicker {
                cell.datePicker.addTarget(self, action: #selector(onStartDateChange), for: .valueChanged);
            } else if indexPath == IndexPath.endDatePicker {
                cell.datePicker.addTarget(self, action: #selector(onEndDateChage), for: .valueChanged);
            }
            return cell
        case IndexPath.comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.className, for: indexPath) as! TextViewTableViewCell
            cell.textView.delegate = self
            cell.textView.text = self.currentUserTrip.comment
            return cell
        default:
            return UITableViewCell(frame: CGRect.zero)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath.startDate: // Start date
            self.hideKeyboard()
            self.updateStartDatePicker(isShown: !self.startDatePickerShown)
        case IndexPath.endDate: // End date
            self.hideKeyboard()
            self.updateEndDatePicker(isShown: !self.endDatePickerShown)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Date picker change
    @objc func onStartDateChange(_ sender: UIDatePicker) {
        self.currentUserTrip.startDate = sender.date
        self.updateSaveButton()
        self.tableView.reloadRows(at: [IndexPath.startDate], with: .none)
        // incase the new date is invalid, we need to strike the end date
        self.tableView.reloadRows(at: [IndexPath.endDate], with: .none)
    }
    
    @objc func onEndDateChage(_ sender: UIDatePicker) {
        self.currentUserTrip.endDate = sender.date
        self.updateSaveButton()
        self.tableView.reloadRows(at: [IndexPath.endDate], with: .none)
    }
    
    // MARK: - text field delegate (Destination)
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.startDatePickerShown || self.endDatePickerShown {
            self.collapseDatePickers() {
                textField.becomeFirstResponder()
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            self.currentUserTrip.destination = updatedText
            self.updateSaveButton()
        }
        return true
    }
    
    // MARK: - text view delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.startDatePickerShown || self.endDatePickerShown {
            self.collapseDatePickers() {
                textView.becomeFirstResponder()
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            if textView.selectedRange.location == textView.text.count {
                self.tableView.scrollToRow(at: IndexPath.comment, at: .bottom, animated: false)
            }
        }
        self.currentUserTrip.comment = textView.text
        self.updateSaveButton()
    }
    
    // MARK: - helpers
    func updateSaveButton() {
        self.navigationItem.rightBarButtonItem?.isEnabled = !self.currentUserTrip.isEqual(self.initialUserTrip)
    }
    
    // MARK: - helpers
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func doTableUpdate(action:()->Void, completion:(() -> Void)? = nil) {
        CATransaction.begin()
        tableView.beginUpdates()
        if let fn = completion {
            CATransaction.setCompletionBlock(fn)
        }
        action()
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func collapseDatePickers(completion:(() -> Void)? = nil) {
        if self.startDatePickerShown {
            self.updateStartDatePicker(isShown: false,completion: completion)
        } else if self.endDatePickerShown {
            self.updateEndDatePicker(isShown: false,completion: completion)
        } else if let fn = completion {
            fn()
        }
    }
    
    func updateStartDatePicker(isShown:Bool, completion:(() -> Void)? = nil) {
        guard self.startDatePickerShown != isShown else {
            return
        }
        self.updateEndDatePicker(isShown: false)
        
        self.doTableUpdate(action: {
            self.startDatePickerShown = isShown
            if isShown {
                self.tableView.insertRows(at: [IndexPath.startDatePicker], with: .fade)
            } else {
                self.tableView.deleteRows(at: [IndexPath.startDatePicker], with: .fade)
            }
        }, completion: completion)
    }
    
    func updateEndDatePicker(isShown:Bool, completion:(() -> Void)? = nil) {
        guard self.endDatePickerShown != isShown else {
            return
        }
        
        self.updateStartDatePicker(isShown: false)
        
        self.doTableUpdate(action: {
            self.endDatePickerShown = isShown
            if isShown {
                self.tableView.insertRows(at: [IndexPath.endDatePicker], with: .fade)
            } else {
                self.tableView.deleteRows(at: [IndexPath.endDatePicker], with: .fade)
            }
        }, completion: completion)
    }
}
