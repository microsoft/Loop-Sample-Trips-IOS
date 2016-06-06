//
//  menuViewController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 6/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

class menuViewController: UIViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if segue.identifier == "tripsSegue" {
			let tableVC : TripTableController = segue.destinationViewController as! TripTableController
			tableVC.showTrips = true
		} else if segue.identifier == "drivesSegue" {
			let tableVC : TripTableController = segue.destinationViewController as! TripTableController
			tableVC.showTrips = false
		}
	}
}
