//
//  Logger.swift
//  Loop Trips Sample
//
//  Created by Xuwen Cao on 6/3/16.
//  Copyright © 2016 Microsoft. All rights reserved.
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

import UIKit
import LoopSDK

class Logger: UIViewController, LogManagerListener {
	let logManager = LoopSDK.logManager;
	let locationManager = LoopSDK.loopLocationProvider;
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
