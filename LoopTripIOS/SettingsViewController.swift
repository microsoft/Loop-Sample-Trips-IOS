//
//  SettingsViewController.swift
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
        touLink.attributedText = createAttributedStringWithLink(linkText: "TERMS".localized, linkUrlString: "https://go.microsoft.com/fwlink/?LinkID=530144", fontSize: 12.0)
        privacyLink.attributedText = createAttributedStringWithLink(linkText: "PRIVACY".localized, linkUrlString: "https://go.microsoft.com/fwlink/?LinkId=521839", fontSize: 12.0)
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
        
        return NSAttributedString(string: linkText, attributes: linkAttributes)
    }
}
