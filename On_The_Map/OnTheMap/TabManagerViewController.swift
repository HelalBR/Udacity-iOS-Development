//
//  TabManagerViewController.swift
//  OnTheMap
//
//  Created by Alan Helal on 22/02/2017.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import UIKit

class TabManagerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    // Launch VC to add a new pin
    @IBAction func addNewPin(_ sender: UIBarButtonItem) {
        
        if StudentDataSource.sharedInstance.locationExists {
            let existAlert = UIAlertController(title: "Warning!", message: "Your location already exists. Do you want to overwrite it?", preferredStyle: .alert)
            existAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            existAlert.addAction(UIAlertAction(title: "Overwrite!", style: .destructive, handler: {control in
                let addNewPinNavigationViewController = self.storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationInputController) as! UINavigationController
                self.present(addNewPinNavigationViewController, animated: true, completion: nil)
            }))
            self.present(existAlert, animated: false, completion: nil)
        } else {
            let addNewPinNavigationViewController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationInputController) as! UINavigationController
            self.present(addNewPinNavigationViewController, animated: true, completion: nil)
        }
    }
    
    // Refresh button - common for Map and List
    // TODO: Refresh main data storing array in Model - check that update is applied to Map/List VCs
    @IBAction func refreshStudentLocations(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
            if success {
                performUIUpdatesOnMain {
                    // Confirm the update with AlertView
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.success, message: "Database updated", actionTitle: ParseClient.ErrorStrings.dismiss)
                    
                    // Update the table ('list') view
                    ListViewController.sharedInstance().tableView.reloadData()
                    
                    // TODO: Refresh map view
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().deleteSessionID(completionHandlerForDeleteSessionID: {(success, error) in
            if success {
                print("ID deleted")
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
}
