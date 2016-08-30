//
//  DriveViewController.swift
//  Loop-Trip
//

import Foundation
import UIKit

class DriveViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellViewHeight: CGFloat = 94.0
    var driveModel = DriveModel.sharedInstance
    var knownLocationsModel = KnownLocationModel.sharedInstance
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DriveViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // turn off the standard separator, we have a custom separator
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        self.driveModel.loadData({
            self.tableView.reloadData()
        })
        
        self.tableView.addSubview(self.refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.driveModel.loadData({
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.driveModel.tableData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.driveModel.tableData[indexPath.row].isSampleData) {
            return cellViewHeight
        }
        else {
            return cellViewHeight - 24.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        let row = self.driveModel.tableData[indexPath.row]
        cell.initialize(row.data!, sampleTrip: row.isSampleData)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.driveModel.tableData[indexPath.row].shouldShowMap {
            self.performSegueWithIdentifier("showMapViewForDrives", sender: indexPath)
        } else {
            self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapViewForDrives", let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.showTrips = false
                mapView.tripData = self.driveModel.tableData[indexPath.row].data
            }
        }
    }
}
