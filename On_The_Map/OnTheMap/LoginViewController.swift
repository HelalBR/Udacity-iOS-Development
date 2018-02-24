//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alan Helal on 22/02/2017.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import UIKit
import MapKit

class LoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: properties
    let locationManager = CLLocationManager()
    
    // MARK: Outlets
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        // Start Location manager
        CLLocationManager.locationServicesEnabled()
        locationManager.startUpdatingLocation()
        
        // Assign text fields delegates
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset login-password fields
        loginTextField.text = nil
        passwordTextField.text = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Actions
    
    @IBAction private func loginWithUdacity(_ sender: UIButton) {
        
        // Start Activity indicator
        self.view.bringSubview(toFront: loginActivityIndicator)
        loginActivityIndicator.startAnimating()
        
        // Start LOGIN process
        ParseClient.sharedInstance().getSessionAndUserID(loginVC: self, completionHandlerForLogin: {(success, error) in
            if success {
                ParseClient.sharedInstance().getInitialUserInfo(completionHandlerForGetIserInfo: {(success, error) in
                    if success {
                        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
                            if success {
                                performUIUpdatesOnMain {
                                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                                    self.completeLogin() // Proceed with the next scene
                                }
                            } else {
                                performUIUpdatesOnMain {
                                    
                                    // Alert: Download of all Student Locations failed
                                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.localizedDescription, actionTitle: ParseClient.ErrorStrings.dismiss)
                                }
                            }
                        })
                    } else {
                        performUIUpdatesOnMain {
                            
                            // Alert: Get initial user info failed
                            self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.localizedDescription, actionTitle: ParseClient.ErrorStrings.dismiss)
                        }
                    }
                })
            } else {
                performUIUpdatesOnMain {
                    
                    // Alert:
                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.localizedDescription, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
    
    private func completeLogin() {
        let navigationManagerController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationManagerController) as! UINavigationController
        self.present(navigationManagerController, animated: true, completion: nil)
    }
    
    // MARK: Location Manager Delegate Functions
    // Get user's coordinates and update Model's properties
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        StudentDataSource.sharedInstance.myLocation?.latitude = userLocation.coordinate.latitude
        StudentDataSource.sharedInstance.myLocation?.longitude = userLocation.coordinate.longitude
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

