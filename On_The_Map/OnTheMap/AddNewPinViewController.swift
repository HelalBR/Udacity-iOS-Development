//
//  AddNewPinViewController.swift
//  OnTheMap
//
//  Created by Alan Helal on 22/02/2017.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import UIKit
import MapKit

class AddNewPinViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var setNewLocationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNewLocationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to KB notifications in order to move view once KB appears
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from KB notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnTheMap(_ sender: UIButton) {
        
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        
        if let mapString = setNewLocationTextField.text, mapString != "" {
            
            // Change corresponding myLocation properties: mapString, Udacity ID, and coordinates
            StudentDataSource.sharedInstance.myLocation?.mapString = mapString
            StudentDataSource.sharedInstance.myLocation?.uniqueKey = ParseClient.Constants.exampleUdacityID
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(mapString, completionHandler: {(placemarks, error) in
                if let placemark = placemarks?[0] {
                    StudentDataSource.sharedInstance.myLocation?.latitude = placemark.location!.coordinate.latitude
                    StudentDataSource.sharedInstance.myLocation?.longitude = placemark.location!.coordinate.longitude
                    self.activityIndicator.stopAnimating()
                    
                    // Instantiate and push PlaceNewPinVC
                    let placeNewPinVC = self.storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.placeNewPinController) as! PlaceNewPinViewController
                    self.navigationController?.pushViewController(placeNewPinVC, animated: true)
                } else {
                    self.activityIndicator.stopAnimating()
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Could not geocode your location!", actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            })
            
            
        } else {
            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Location name cannot be empty!", actionTitle: ParseClient.ErrorStrings.dismiss)
        }
    }
    
    // MARK: Singleton shared instance
    // TODO: Do I need it?
    class func sharedInstance() -> AddNewPinViewController {
        struct Singleton {
            static let sharedInstance = AddNewPinViewController()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setNewLocationTextField.resignFirstResponder()
        return true
    }
    
    // viewWillTransition - hide keyboard while turning device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setNewLocationTextField.resignFirstResponder()
    }
    
    // MARK: - Move the view when KB appears
    func keyboardWillShow(notification: NSNotification) {
        if setNewLocationTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification: notification) * (-1)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: - Subscribe/unsubscribe to notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}
