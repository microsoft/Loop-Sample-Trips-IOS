//
//  AppDelegate.swift
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

import UIKit
import LoopSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoopSDKListener {

	var window: UIWindow?
	var loopInitialized = false;
    
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		var appID = ""
		var appToken = ""
        
		if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
			let dict = NSDictionary(contentsOfFile: path) {
			
			if let userId = dict["LOOP_USER_ID_PROP"] as? String where userId != "",
				let deviceId = dict["LOOP_DEVICE_ID_PROP"] as? String where deviceId != "" {
				LoopSDK.setUserID(userId)
				LoopSDK.setDeviceID(deviceId)
			}
			
			if let appID_plist = dict["LOOP_APP_ID_PROP"] as? String where appID_plist != "",
				let appToken_plist = dict["LOOP_APP_TOKEN_PROP"] as? String where appToken_plist != "" {
				appID = appID_plist;
				appToken = appToken_plist;
			}
		}
		
		LoopSDK.initialize(self, appID: appID, token: appToken);
		LoopSDK.logManager.logEvent("Launch option \(launchOptions)")
        
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


	func onLoopInitialized() {
		NSLog("Loop SDK successfully initialized")

		loopInitialized = true;

        // let the system prompt for location access
        if (!LoopSDK.loopLocationProvider.active) {
            LoopSDK.loopLocationProvider.startListener()
        }
	}
	
	func onLoopInitializeError(error: String) {
		NSLog("Loop SDK initialization error: \(error)")
		
		loopInitialized = false;
		
	}
}

