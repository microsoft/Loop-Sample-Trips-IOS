//
//  TripViewController.swift
//  Loop-Trip
//

import Foundation
import UIKit

class TripViewController: UIViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if self.restorationIdentifier == "drivesViewController", let tableView = segue.destinationViewController as? TripTableController {
            tableView.showTrips = false
        }
        else if self.restorationIdentifier == "tripsViewController", let tableView = segue.destinationViewController as? TripTableController {
            tableView.showTrips = true
        }
    }
}
