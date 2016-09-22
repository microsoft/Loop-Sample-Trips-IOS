//
//  SettingsViewController.swift
//  Trips App
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
    @IBOutlet weak var learnLoopLink: UITextView!
    @IBOutlet weak var touLink: UITextView!
    @IBOutlet weak var privacyLink: UITextView!
    @IBOutlet weak var versionString: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        if (!LoopSDK.isInitialized()) {
            recordingSwitch.isEnabled = false
        }
        else {
            recordingSwitch.isEnabled = true
            
            recordingSwitch.setOn((LoopSDK.loopLocationProvider.active && LoopSDK.loopLocationProvider.listenerStatus == CLAuthorizationStatus.authorizedAlways), animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buildVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionString.text = "v" + buildVersion!
        
        learnLoopLink.attributedText = createAttributedStringWithLink(linkText: "LEARN_ABOUT_LOOP".localized, linkUrlString: "https://www.loop.ms", fontSize: 14.0)
        touLink.attributedText = createAttributedStringWithLink(linkText: "TERMS".localized, linkUrlString: "http://go.microsoft.com/fwlink/?LinkID=530144", fontSize: 12.0)
        privacyLink.attributedText = createAttributedStringWithLink(linkText: "PRIVACY".localized, linkUrlString: "http://go.microsoft.com/fwlink/?LinkId=521839", fontSize: 12.0)
    }
    
// MARK - Actions
    
    @IBAction func onRecordingSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let listenerStatus = LoopSDK.loopLocationProvider.listenerStatus
            if  (listenerStatus == CLAuthorizationStatus.authorizedAlways) {
                LoopSDK.loopLocationProvider.startListener()
            } 
            else {
                // set the button to off and ask for permission
                sender.setOn(false, animated: false)
                
                AlertUtils.AlertWithCallback(uiView: self, title: "Authorization Required".localized,
                                                            message: "AUTH_REQUIRED_MESSAGE".localized,
                                                            confirmButtonText: "Go to Settings".localized, callback: {
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                })
            }
        } else {
            LoopSDK.loopLocationProvider.stopListener()
        }
    }
    
    @IBAction func deleteUserData(_ sender: AnyObject) {
        AlertUtils.AlertWithCallback(uiView: self, title: "Delete All Trip Data".localized,
                                                    message: "DELETE_USERDATA_MESSAGE".localized,
                                                    confirmButtonText: "Delete".localized,
                                                    callback: {
                                                        self.recordingSwitch.setOn(false, animated: false)
                                                        
                                                        LoopSDK.deleteUser({
                                                            error, response, JSON in
                                                            if let status = response?.statusCode, status < 300 {
                                                                AlertUtils.Alert(uiView: self, title: "Delete Successfull".localized, message: "BEGIN_RECORDING_TRIPS_MESSAGE".localized)
                                                            }
                                                            else {
                                                                AlertUtils.Alert(uiView: self, title: "Error".localized, message: "DELETE_USERDATA_ERROR_MESSAGE".localized)
                                                            }
                                                        })
                                                    })

    }
}


// MARK - Privates

extension SettingsViewController {
    fileprivate func createAttributedStringWithLink(linkText: String, linkUrlString: String, fontSize: CGFloat) -> NSAttributedString {
        let linkAttributes = [
            NSLinkAttributeName: NSURL(string: linkUrlString)!,
            NSFontAttributeName: UIFont(name: "Menlo", size: fontSize)!,
            NSForegroundColorAttributeName: UIColor.settingsLinkTextColor
        ]
        
        return NSAttributedString.init(string: linkText, attributes: linkAttributes)
    }
}
