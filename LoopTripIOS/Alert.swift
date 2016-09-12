//
//  Alert.swift
//  Alert utilities
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
