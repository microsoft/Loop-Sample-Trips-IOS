//
//  TripViewController.swift
//  LoopTrip
//

import Foundation
import UIKit

class TripViewController: UIViewController {
    
    @IBOutlet weak var tripTableView: UITableView!

    private var repositoryManagerUpdateObserver: NSObjectProtocol!
    
    let cellViewHeight: CGFloat = 94.0
    let repositoryManager = RepositoryManager.sharedInstance
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TripViewController.onPullToRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewWillDisappear(animated: Bool) {
        if let repositoryManagerUpdateObserver = repositoryManagerUpdateObserver {
            NSNotificationCenter.defaultCenter().removeObserver(repositoryManagerUpdateObserver)
        }
    }

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
        self.tripTableView.separatorColor = UIColor.clearColor()
        self.tripTableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")

        self.repositoryManager.loadRepositoryDataAsync()
        
        self.tripTableView.addSubview(self.refreshControl)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapViewForTrips", let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.setData((self.repositoryManager.tripRepository.tableData[indexPath.row].data)!, showTrips: false)
            }
        }
    }
}


// MARK - Privates

extension TripViewController {
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        self.repositoryManager.loadRepositoryDataAsync()
        
        refreshControl.endRefreshing()
    }
    
    private func contentChangedNotification(notification: NSNotification!) {
        switch notification.name {
        case RepositoryManagerAddedContentNotification:
            NSLog("Received update notification in TripView")
            self.tripTableView.reloadData()
        default:
            NSLog("Unknown notification")
        }
    }
}


// MARK - UITableView Delegate

extension TripViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositoryManager.tripRepository.tableData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.repositoryManager.tripRepository.tableData[indexPath.row].isSampleData) {
            return cellViewHeight
        }
        else {
            return cellViewHeight - 24.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        let row = self.repositoryManager.tripRepository.tableData[indexPath.row]
        cell.setData(row.data!, sampleTrip: row.isSampleData)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showMapViewForTrips", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {
            (action, indexPath) in
            
            self.repositoryManager.tripRepository.removeData(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        deleteAction.backgroundColor = UIColor.tableCellDeleteActionColor
        
        return [deleteAction]
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
