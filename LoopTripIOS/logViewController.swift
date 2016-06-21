//
//  logViewController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 6/3/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import LoopSDK

class logViewController: UIViewController, LogManagerListener {
	let logManager = LoopSDK.logManager;
	let locationManager = LoopSDK.locationManager;
	var logs = [String]();

	@IBOutlet weak var logView: UITextView!
	
	@IBAction func copyClicked(sender: AnyObject) {
		UIPasteboard.generalPasteboard().string = cleanText();
	}

	@IBAction func clearClicked(sender: AnyObject) {
		logManager.clearLog()
	}
	
	override func viewDidLoad() {
		logManager.addListener(self);
		
		logs = logManager.logs;
		
		//display
		logView.text = cleanText()
	}
	
	func onApplicationBecameActive() {
		//app did re-enter active state
		logs = logManager.logs;
		
		//refresh log ui
		logView.text = cleanText()
	}
	
	func onLogChanged() {
		logs = logManager.logs;
		
		//refresh log ui
		logView.text = cleanText()
	}
	
	func cleanText() -> String {
		return logs.reduce("") { return $1+"\n"+$0};
	}
}
