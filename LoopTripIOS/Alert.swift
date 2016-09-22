//
//  Alert.swift
//  Alert utilities
//  Trips App
//
//  MIT License
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
