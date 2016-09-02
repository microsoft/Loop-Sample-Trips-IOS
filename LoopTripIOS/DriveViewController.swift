//
//  DriveViewController.swift
//  LoopTrip
//

import Foundation
import UIKit

class DriveViewController: UIViewController {
    
    @IBOutlet weak var driveTableView: UITableView!
    
    private var driveRepositoryUpdateObserver: NSObjectProtocol!
    private var knownLocationRepositoryUpdateObserver: NSObjectProtocol!

    let cellViewHeight: CGFloat = 94.0
    let driveRepository = DriveRepository.sharedInstance
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DriveViewController.onPullToRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        driveRepositoryUpdateObserver = NSNotificationCenter.defaultCenter()
            .addObserverForName(DriveRepositoryAddedContentNotification,
                                object: nil,
                                queue: NSOperationQueue.mainQueue()) {
                                    notification in
                                    self.contentChangedNotification(notification)
        }
        knownLocationRepositoryUpdateObserver = NSNotificationCenter.defaultCenter()
            .addObserverForName(KnownLocationRepositoryAddedContentNotification,
                                object: nil,
                                queue: NSOperationQueue.mainQueue()) {
                                    notification in
                                    self.contentChangedNotification(notification)
        }
        
        // turn off the standard separator, we have a custom separator
        self.driveTableView.separatorColor = UIColor.clearColor()
        self.driveTableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        self.driveRepository.loadData()
        self.knownLocationRepository.loadData()
        
        self.driveTableView.addSubview(self.refreshControl)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapViewForDrives", let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.setData((self.driveRepository.tableData[indexPath.row].data)!, showTrips: false)
            }
        }
    }
}


// MARK - Privates

extension DriveViewController {
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        self.loadRepositoryDataAsync()
        
        refreshControl.endRefreshing()
    }
    
    private func loadRepositoryDataAsync() {
        self.driveRepository.loadData()
        self.knownLocationRepository.loadData()
    }
    
    private func contentChangedNotification(notification: NSNotification!) {
        switch notification.name {
        case DriveRepositoryAddedContentNotification:
            self.driveTableView.reloadData()
        case KnownLocationRepositoryAddedContentNotification:
            self.view.setNeedsDisplay()
        default:
            NSLog("Unknown notification")
        }
    }
}


// MARK - UITableView Delegate

extension DriveViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.driveRepository.tableData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.driveRepository.tableData[indexPath.row].isSampleData) {
            return cellViewHeight
        }
        else {
            return cellViewHeight - 24.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        let row = self.driveRepository.tableData[indexPath.row]
        cell.setData(row.data!, sampleTrip: row.isSampleData)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showMapViewForDrives", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {
            (action, indexPath) in
            
            self.driveRepository.removeData(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        deleteAction.backgroundColor = UIColor.tableCellDeleteActionColor
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
