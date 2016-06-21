//
//  TrackViewController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 6/2/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import LoopSDK

class TrackViewController: UIViewController {
	let locationManager = LoopSDK.locationManager;
	
	@IBOutlet weak var credentialView: UITextView!
	
	@IBAction func syncClicked(sender: AnyObject) {
		LoopSDK.syncManager.forceSendSignals();
	}
	
	@IBAction func trackToggled(sender: UISwitch) {
		if sender.on {
			LoopSDK.locationManager.startListener()
		} else {
			LoopSDK.locationManager.stopListener()
		}
	}
	
	@IBOutlet weak var trackSwitch: UISwitch!
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		if let userId = LoopSDK.getUserID(), let deviceId = LoopSDK.getDeviceID() {
			credentialView.text = "UserID: \(userId)\nDeviceID: \(deviceId)"
		}

		if LoopSDK.locationManager.active {
			trackSwitch.setOn(true, animated: false);
		}
	}
}
