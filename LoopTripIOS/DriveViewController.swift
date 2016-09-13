//
//  DriveViewController.swift
//  Loop Trips Sample
//
//  Copyright (c) Microsoft Corporation
//
//  All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the License); you may not 
//  use this file except in compliance with the License. You may obtain a copy 
//  of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS 
//  OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY 
//  IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE, 
//  MERCHANTABLITY OR NON-INFRINGEMENT.
//
//  See the Apache Version 2.0 License for specific language governing permissions 
//  and limitations under the License.
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
        
        self.driveTableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        self.repositoryManager.loadRepositoryDataAsync(true)
        
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
        self.repositoryManager.loadRepositoryDataAsync(false)
        self.driveTableView.reloadData()
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
        if self.repositoryManager.driveRepository.tableData.count > indexPath.row && self.repositoryManager.driveRepository.tableData[indexPath.row].isSampleData {
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
