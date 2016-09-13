//
//  SettingsViewController.swift
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

import Foundation
import UIKit
import CoreLocation
import LoopSDK

class SettingsViewController: UIViewController {
    @IBOutlet weak var recordingSwitch: UISwitch!
    @IBOutlet weak var userIdTextButton: UIButton!
    @IBOutlet weak var deviceIdTextButton: UIButton!
    @IBOutlet weak var learnLoopLink: UITextView!
    @IBOutlet weak var touLink: UITextView!
    @IBOutlet weak var privacyLink: UITextView!
    @IBOutlet weak var versionString: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buildVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        versionString.text = "v" + buildVersion!
        
        if (LoopSDK.isInitialized()) {
            userIdTextButton.setTitle(LoopSDK.getUserID(), forState: .Normal)
            deviceIdTextButton.setTitle(LoopSDK.getDeviceID(), forState: .Normal)
            
            recordingSwitch.enabled = true
            recordingSwitch.setOn(LoopSDK.loopLocationProvider.active, animated: false)
        }
        else {
            userIdTextButton.setTitle("UNINITIALIZED", forState: .Normal)
            deviceIdTextButton.setTitle("UNINITIALIZED", forState: .Normal)

            recordingSwitch.enabled = false
        }
        
        learnLoopLink.attributedText = createAttributedStringWithLink("Learn more about Microsoft Location Observation Platform (LOOP)...", linkUrlString: "https://www.loop.ms", fontSize: 14.0)
        touLink.attributedText = createAttributedStringWithLink("TERMS", linkUrlString: "http://go.microsoft.com/fwlink/?LinkID=530144", fontSize: 12.0)
        privacyLink.attributedText = createAttributedStringWithLink("PRIVACY", linkUrlString: "http://go.microsoft.com/fwlink/?LinkId=521839", fontSize: 12.0)
    }
    
    @IBAction func onRecordingSwitch(sender: UISwitch) {
        if sender.on {
            let listenerStatus = LoopSDK.loopLocationProvider.listenerStatus
            if  (listenerStatus == CLAuthorizationStatus.AuthorizedAlways
                    || listenerStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
                LoopSDK.loopLocationProvider.startListener()
            } 
            else {
                // set the button to off and ask for permission
                sender.setOn(false, animated: false)
                
                let alertController: UIAlertController = UIAlertController(title: "Authorization Required", message: "You need to allow this app to to access Location in Settings.", preferredStyle: .Alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                }
                alertController.addAction(cancelAction)
                
                let settingsAction: UIAlertAction = UIAlertAction(title: "Go to Settings", style: .Default) { action -> Void in
                    dispatch_async(GlobalMainQueue) {
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                    }
                }
                alertController.addAction(settingsAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            LoopSDK.loopLocationProvider.stopListener()
        }
    }
}


// MARK - Private

extension SettingsViewController {
    private func createAttributedStringWithLink(linkText: String, linkUrlString: String, fontSize: CGFloat) -> NSAttributedString {
        let linkAttributes = [
            NSLinkAttributeName: NSURL(string: linkUrlString)!,
            NSFontAttributeName: UIFont(name: "Menlo", size: fontSize)!,
            NSForegroundColorAttributeName: UIColor.settingsLinkTextColor
        ]
        
        return NSAttributedString.init(string: linkText, attributes: linkAttributes)
    }
}


// MARK - UIButton
extension SettingsViewController {
    @IBAction func userIdButton(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = userIdTextButton.titleLabel!.text
        
        AlertUtils.Alert(self, title: "Copied to Clipboard", message: userIdTextButton.titleLabel!.text!)
    }
    
    @IBAction func deviceIdButton(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = deviceIdTextButton.titleLabel!.text

        AlertUtils.Alert(self, title: "Copied to Clipboard", message: deviceIdTextButton.titleLabel!.text!)
    }
}
