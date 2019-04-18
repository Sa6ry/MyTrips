//
//  UserTripsViewController+Print.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/26/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

extension UserTripsViewController {
    
    fileprivate func printUserTrips(_ userTrips:[UserTrip]) {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "MyTrips"
        printInfo.orientation = .portrait
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = false
        
        
        let htmlUserTrips = userTrips.map{"""
            <tr style='page-break-after:avoid'><td style='font-family:HelveticaNeue-Medium'>Destination</td><td>:</td><td width=100%>\($0.destination)</td></tr>
            <tr style='page-break-after:avoid'><td style='font-family:HelveticaNeue-Medium'>Start&nbsp;Date</td><td>:</td><td>\($0.startDate.fullDate)</td></tr>
            <tr style='page-break-after:avoid'><td style='font-family:HelveticaNeue-Medium'>End&nbsp;Date</td><td>:</td><td>\($0.endDate.fullDate)</td></tr>
            <tr style='page-break-after:avoid;\($0.comment.count == 0 ? "display:none":"")'><td  style='font-family:HelveticaNeue-Medium'>Comment</td><td>:</td><td>\($0.comment)</td></tr>
            """
            }.joined(separator: "<tr><td colspan=3>&nbsp;</td></tr>")
        let htmlPage = "<html><body style='font-family:Helvetica'><table width=100% cellpadding=5><tr style='background-color:rgb(255, 255, 255);'><td style='font-size:40px;padding-bottom:40px;font-family:Helvetica-bold' colspan=3>My Trips</td></tr>\(htmlUserTrips)</table></body></html>"
        
        let formatter = UIMarkupTextPrintFormatter.init(markupText: htmlPage)
        printController.printFormatter = formatter
        printController.present(animated: true, completionHandler: nil)
    }
    
    fileprivate func printAllTrips() {
        if self.userTrips.count == 0 {
            self.showMessageBox(message: "No trips found")
        } else {
            self.printUserTrips(self.userTrips)
        }
    }
    
    fileprivate func printNextMonthTrips() {
        let today = Calendar.current.startOfDay(for: Date.init())
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: today)
        let nextMonthTrips = self.userTrips.filter({$0.startDate <= nextMonth! && $0.startDate >= today})
        if nextMonthTrips.count == 0 {
            self.showMessageBox(message: "No trips found")
        } else {
            self.printUserTrips(nextMonthTrips)
        }
    }
    
    func onPrintUserTrips() {
        let alert = UIAlertController(title: "Print", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "All trips", style: .default, handler: { (alert) in
            self.printAllTrips()
        }))
        alert.addAction(UIAlertAction(title: "Next Month Trips", style: .default, handler: { (alert) in
            self.printNextMonthTrips()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
