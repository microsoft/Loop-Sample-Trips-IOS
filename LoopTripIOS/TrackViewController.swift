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
		
		if let userId = LoopSDK.getUserID() {
			credentialView.text = "UserID: \(userId)\n"
		}

		if LoopSDK.locationManager.active {
			trackSwitch.setOn(true, animated: false);
		}
	}
}
