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
	var tableData:[(text: String, shouldShowMap: Bool, data:LoopTrip?)] = [
		(text:"Get trips", shouldShowMap:false, data:nil)
	];
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
			(self.parentViewController as! TripNavigationConntroller).pushViewController(vc, animated: true)
		} else {
			self.tableView.deselectRowAtIndexPath(indexPath, animated:true);
			
			if (tableData[row].text == "Get trips") {
				if !getLoopInitialized() {
					self.tableData.removeAll();
					self.tableData.append((text: "Get trips", shouldShowMap:false, data:nil))
					self.tableData.append((text: "SDK credential error!", shouldShowMap:false, data:nil))
					self.tableView.reloadData();
					return;
				}
				
				LoopSDK.syncManager.getTrips {
					(loopTrips:[LoopTrip]) in
					
					self.tableData.removeAll();
					self.tableData.append((text: "Get trips", shouldShowMap:false, data:nil))
					
					if loopTrips.isEmpty {
						self.tableData.append((text: "No trips!", shouldShowMap:false, data: nil));
					} else {
						loopTrips.forEach { trip in
							self.tableData.append((text: "started:\(trip.startedAt.toLocalStringWithFormat()) distance:\(trip.distanceTraveledInKilometers)Km", shouldShowMap:true, data:trip));
						}
					}
					
					self.tableView.reloadData();
				}
			}
		}
	}
	
	func getLoopInitialized() -> Bool {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return appDelegate.loopInitialized
	}
}