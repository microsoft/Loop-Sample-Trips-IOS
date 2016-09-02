//
//  DriveViewController.swift
//  LoopTrip
//

import Foundation
import UIKit

class DriveViewController: UIViewController {
    
    @IBOutlet weak var driveTableView: UITableView!
    
    private var repositoryManagerUpdateObserver: NSObjectProtocol!

    let cellViewHeight: CGFloat = 94.0
    let repositoryManager = RepositoryManager.sharedInstance
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DriveViewController.onPullToRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repositoryManagerUpdateObserver = NSNotificationCenter.defaultCenter()
            .addObserverForName(RepositoryManagerAddedContentNotification,
                                object: nil,
                                queue: NSOperationQueue.mainQueue()) {
                                    notification in
                                    self.contentChangedNotification(notification)
        }
        
        // turn off the standard separator, we have a custom separator
        self.driveTableView.separatorColor = UIColor.clearColor()
        self.driveTableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        self.repositoryManager.loadRepositoryDataAsync()
        
        self.driveTableView.addSubview(self.refreshControl)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapViewForDrives", let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.setData((self.repositoryManager.driveRepository.tableData[indexPath.row].data)!, showTrips: false)
            }
        }
    }
}


// MARK - Privates

extension DriveViewController {
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        self.repositoryManager.loadRepositoryDataAsync()
        
        refreshControl.endRefreshing()
    }
    
    private func contentChangedNotification(notification: NSNotification!) {
        switch notification.name {
        case RepositoryManagerAddedContentNotification:
            NSLog("Received update notification in DriveView")
            self.driveTableView.reloadData()
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
        return self.repositoryManager.driveRepository.tableData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.repositoryManager.driveRepository.tableData[indexPath.row].isSampleData) {
            return cellViewHeight
        }
        else {
            return cellViewHeight - 24.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        let row = self.repositoryManager.driveRepository.tableData[indexPath.row]
        cell.setData(row.data!, sampleTrip: row.isSampleData)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showMapViewForDrives", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {
            (action, indexPath) in
            
            self.repositoryManager.driveRepository.removeData(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        deleteAction.backgroundColor = UIColor.tableCellDeleteActionColor
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
