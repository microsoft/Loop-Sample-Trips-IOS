//
//  Alert.swift
//  Alert utilities
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

class AlertUtils {
    class func Alert(uiView: UIViewController, title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK".localized, style: .default) { action -> Void in
            alertController.dismiss(animated: true, completion: {
            })
        }
        alertController.addAction(okAction)
        
        uiView.present(alertController, animated: true, completion: nil)
    }
    
    class func AlertWithCallback(uiView: UIViewController, title: String, message: String, confirmButtonText: String, callback: @escaping (Void) -> Void) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { action -> Void in
        }
        alertController.addAction(cancelAction)
        
        let settingsAction: UIAlertAction = UIAlertAction(title: confirmButtonText, style: .default) { action -> Void in
            DispatchQueue.main.async {
                callback()
            }
        }
        alertController.addAction(settingsAction)
        
        uiView.present(alertController, animated: true, completion: nil)
    }
}
