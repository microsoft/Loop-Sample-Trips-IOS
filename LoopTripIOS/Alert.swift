//
//  Alert.swift
//  Alert utilities
//  Loop Trips Sample
//

import Foundation
import UIKit

class AlertUtils {
    class func Alert(uiView: UIViewController, title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            alertController.dismissViewControllerAnimated(true, completion: {
            })
        }
        alertController.addAction(okAction)
        
        uiView.presentViewController(alertController, animated: true, completion: nil)
    }
}
