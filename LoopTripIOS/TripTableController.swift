//
//  TripTableController.swift
//  Loop-Sample-Trip-IOS
//

import UIKit
import LoopSDK

class TripTableController: UITableViewController {
    let cellViewHeight: CGFloat = 94.0
    var tripModel = TripModel.sharedInstance
    var showTrips = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // turn off the standard separator, we have a custom separator
        self.tableView.separatorColor = UIColor.clearColor()
                
        self.tableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        tripModel.loadData(showTrips, loadDataCompletion: {() -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripModel.tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.tripModel.tableData[indexPath.row].isSampleData) {
            return cellViewHeight
        }
        else {
            return cellViewHeight - 24.0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        let row = self.tripModel.tableData[indexPath.row]
        cell.initialize(row.data!, sampleTrip: row.isSampleData)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        if self.tripModel.tableData[row].shouldShowMap {
            self.performSegueWithIdentifier(self.showTrips ? "showMapViewForTrips" : "showMapViewForDrives", sender: indexPath)
        } else {
            self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueId = self.showTrips ? "showMapViewForTrips" : "showMapViewForDrives"
        if segue.identifier == segueId, let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.showTrips = self.showTrips
                mapView.tripData = self.tripModel.tableData[indexPath.row].data
            }
        }
    }
}
