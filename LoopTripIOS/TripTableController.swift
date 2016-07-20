//
//  TripTableController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 5/30/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import LoopSDK

extension NSDate {
 public func toSimpleString() -> String {
	// change to a readable time format and change to local time zone
	let dateFormatter = NSDateFormatter()
	dateFormatter.dateFormat = "MM-dd'T'HH:mm"
	dateFormatter.timeZone = NSTimeZone.localTimeZone()
	let timeStamp = dateFormatter.stringFromDate(self)
	
	return timeStamp
	}
}

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
						var locales = "";
						let start = trip.startLocale?.getFriendlyName();
						let end = trip.endLocale?.getFriendlyName();
						if start != nil && end != nil {
							locales = "\(start!)->\(end!)"
						}
						self.tableData.append((text: "\(trip.startedAt.toSimpleString()) \(trip.distanceTraveledInKilometers)Km \(locales)", shouldShowMap:true, data:trip));
					}
				}
				
				self.tableView.reloadData();
		}

		if (showTrips) {
			LoopSDK.syncManager.getTrips(40, callback: completion);
		} else {
			LoopSDK.syncManager.getDrives(40, callback: completion);
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