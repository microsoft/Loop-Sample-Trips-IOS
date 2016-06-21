//
//  TripTableController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 5/30/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import LoopSDK

class TripTableController: UITableViewController {
	var tableData:[(text: String, shouldShowMap: Bool, data:LoopTrip?)] = [];
	var showTrips = true;

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let completion = {
				(loopTrips:[LoopTrip]) in
				
				self.tableData.removeAll();
				
				if loopTrips.isEmpty {
					let text = self.showTrips ? "No trips" : "No drives"
					self.tableData.append((text: text, shouldShowMap:false, data: nil));
				} else {
					loopTrips.forEach { trip in
						self.tableData.append((text: "started:\(trip.startedAt.toLocalStringWithFormat()) distance:\(trip.distanceTraveledInKilometers)Km", shouldShowMap:true, data:trip));
					}
				}
				
				self.tableView.reloadData();
		}

		if (showTrips) {
			LoopSDK.syncManager.getTrips(completion);
		} else {
			LoopSDK.syncManager.getDrives(completion);
		}
		
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath)
		
		let row = indexPath.row
		cell.textLabel?.text = tableData[row].text;
		
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {		
		let row = indexPath.row

		if tableData[row].shouldShowMap {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
			vc.tripData = tableData[row].data;
			(self.parentViewController as! UINavigationController).pushViewController(vc, animated: true)
		} else {
			self.tableView.deselectRowAtIndexPath(indexPath, animated:true);
		}
	}
	
	func getLoopInitialized() -> Bool {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return appDelegate.loopInitialized
	}
}