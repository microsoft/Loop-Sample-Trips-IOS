//
//  Logger.swift
//  Trips App
//
//  Copyright (c) 2016 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import LoopSDK

class Logger: UIViewController, LogManagerListener {
	let logManager = LoopSDK.logManager
	let locationManager = LoopSDK.loopLocationProvider
	var logs = [String]()

	@IBOutlet weak var logView: UITextView!
	
	@IBAction func copyClicked(sender: AnyObject) {
		UIPasteboard.general.string = cleanText()
	}

	@IBAction func clearClicked(sender: AnyObject) {
		logManager?.clearLog()
	}
	
	override func viewDidLoad() {
		logManager?.addListener(self)
		
		logs = (logManager?.logs)!
		
		//display
		logView.text = cleanText()
	}
	
	func onApplicationBecameActive() {
		//app did re-enter active state
		logs = (logManager?.logs)!
		
		//refresh log ui
		logView.text = cleanText()
	}
	
	func onLogChanged() {
		logs = (logManager?.logs)!
		
		//refresh log ui
		logView.text = cleanText()
	}
	
	func cleanText() -> String {
		return logs.reduce("") { return $1+"\n"+$0}
	}
}
