//
//  SettingsViewController.swift
//  LoopTrip
//

import Foundation
import UIKit
import LoopSDK

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var recordingSwitch: UISwitch!
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var deviceIdText: UITextField!
    @IBOutlet weak var learnLoopLink: UITextView!
    @IBOutlet weak var touLink: UITextView!
    @IBOutlet weak var privacyLink: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdText.delegate = self
        deviceIdText.delegate = self
        
        if (LoopSDK.isInitialized()) {
            userIdText.text = LoopSDK.getUserID()
            deviceIdText.text = LoopSDK.getDeviceID()
            
            recordingSwitch.enabled = true
            recordingSwitch.setOn(LoopSDK.loopLocationProvider.active, animated: false)
        }
        else {
            userIdText.text = "UNINITIALIZED"
            deviceIdText.text = "UNINITIALIZED"

            recordingSwitch.enabled = false
        }
        
        learnLoopLink.attributedText = createAttributedStringWithLink("Learn more about Microsoft Location Observation Platform (LOOP)...", linkUrlString: "https://www.loop.ms", fontSize: 14.0)
        touLink.attributedText = createAttributedStringWithLink("TERMS", linkUrlString: "http://go.microsoft.com/fwlink/?LinkID=530144", fontSize: 12.0)
        privacyLink.attributedText = createAttributedStringWithLink("PRIVACY", linkUrlString: "http://go.microsoft.com/fwlink/?LinkId=521839", fontSize: 12.0)
    }
    
    @IBAction func onRecordingSwitch(sender: UISwitch) {
        if sender.on {
            LoopSDK.loopLocationProvider.startListener()
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


// MARK - UITextField

extension SettingsViewController {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false;
    }
}
