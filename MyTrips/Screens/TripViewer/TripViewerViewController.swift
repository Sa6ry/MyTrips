//
//  TripViewerViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/23/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class TripViewerViewController: UITableViewController, TripEditorViewControllerDelegate {
    
    var userTrip: UserTrip!
    var userInfo: UserInfo!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var durationLabel: UILabel!
    
    var tripViewerDelegate: TripViewerViewControllerDelegate!
    
    class func viewControllerInstance(userTrip: UserTrip, userInfo: UserInfo, tripViewerDelegate: TripViewerViewControllerDelegate) -> UIViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "TripViewer", bundle: nil)
        let vc:TripViewerViewController = storyboard.instantiateInitialViewController() as! TripViewerViewController
        vc.userTrip = userTrip
        vc.userInfo = userInfo
        vc.tripViewerDelegate = tripViewerDelegate
        return vc
    }
    
    override func loadView() {
        super.loadView()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.addRefreshControl()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        
        // add edit button
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(onEdit))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.userTrip.comment.count == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        let vc = TripEditorViewController.navigationViewControllerInstance(userTrip: self.userTrip, tripEditorDelegate: self)
        // vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - trip editor delegate
    
    func onTripEditorAddTrip(_ tripEditorViewController: TripEditorViewController, newUserTrip: UserTrip) {
        self.onUserTripChange(newUserTrip)
        self.updateUI()
        self.tableView.reloadData()
    }
    
    func onTripEditorUpdateTrip(_ tripEditorViewController: TripEditorViewController, updatedUserTrip: UserTrip) {
        self.onUserTripChange(updatedUserTrip)
        self.updateUI()
        self.tableView.reloadData()
    }
    
    //MARK: - Helpers
    func onUserTripChange(_ userTrip: UserTrip) {
        self.userTrip = userTrip
        self.tripViewerDelegate.onTripViewerUpdateTrip(self, updatedUserTrip: userTrip)
        Network.addUserTrip(userInfo: self.userInfo, userTrip: userTrip) {error in
            if let error = error {
                self.showMessageBox(title: "Error", message: error)
            }
        }
        self.updateUI()
        self.tableView.reloadData()
        
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Update Trip Information ...", attributes: nil)
    }

    @objc func refresh() {
        Network.getUserTrip(userInfo: self.userInfo, tripUid: self.userTrip.uuid) { userTrip, error in
            self.userTrip = userTrip
            self.updateUI()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    func updateUI() {
        self.title = self.userTrip.destination
        self.startDateLabel.text = self.userTrip.startDate.fullDate
        self.endDateLabel.text = self.userTrip.endDate.fullDate
        self.commentTextView.text = self.userTrip.comment
        self.dueDateLabel.text = self.tripDueText()
        self.durationLabel.text = "\(self.userTrip.tripDurationInDays) days"
    }
    
    
    func tripDueText() -> String {
        switch self.userTrip.daysToTrip {
        case let days where days == -1: return "Ended 1 day ago"
        case let days where days < 0: return "Ended \(String(-1*days)) days ago"
        case let days where days == 1: return "\(String(days)) day to start"
        case let days where days > 0: return "\(String(days)) days to start"
        default: return "Enjoy your trip!"
        }
    }
}
