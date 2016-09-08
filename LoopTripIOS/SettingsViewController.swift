//
//  SettingsViewController.swift
//  LoopTrip
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
