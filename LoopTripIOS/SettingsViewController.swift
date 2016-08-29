//
//  SettingsViewController.swift
//  Loop-Trip
//

import Foundation
import UIKit
import LoopSDK

class SettingsViewController: UIViewController {
    @IBOutlet weak var recordingSwitch: UISwitch!
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var deviceIdText: UITextField!
    @IBOutlet weak var learnLoopLink: UITextView!
    @IBOutlet weak var touLink: UITextField!
    @IBOutlet weak var privacyLink: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdText.text = LoopSDK.getUserID()
        deviceIdText.text = LoopSDK.getDeviceID()
    }
}
