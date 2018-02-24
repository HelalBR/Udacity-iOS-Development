//
//  GlobalFunctions.swift
//  OnTheMap
//
//  Created by Alan Helal on 22/02/2017.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation
import UIKit

// Perform updates on Main queue
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

// Show alert for errors, messages etc.
func showAlert(viewController: UIViewController, title: String, message: String?, actionTitle: String) -> Void {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
    
    viewController.present(alert, animated: true, completion: nil)
}
