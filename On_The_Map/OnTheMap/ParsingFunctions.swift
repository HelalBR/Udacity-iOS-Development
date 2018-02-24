//
//  ParsingFunctions.swift
//  OnTheMap
//
//  Created by Alan Helal on 22/02/2017.
//  Copyright © 2018 Alan Helal. All rights reserved.
//

import Foundation

// Functions for extracting required data from serialized JSONs
extension ParseClient {
    
    // MARK: Get Session & User IDs
    // Send Request and retrieve Session ID & User ID
    func getSessionAndUserID(loginVC: LoginViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        guard let userName = loginVC.loginTextField.text, let password = loginVC.passwordTextField.text, userName != "", password != "" else {
            completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Login and/or Password is empty"]))
            return
        }
        
        let urlForLoginWithUdacity = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/session", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.post, withURL: urlForLoginWithUdacity, httpHeaderFieldValue: [ParseClient.JSONHeaderField.accept:ParseClient.JSONHeaderValues.appJSON, ParseClient.JSONHeaderField.contentType:ParseClient.JSONHeaderValues.appJSON], httpBody: "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}", completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                // Launch completion handler with parms for unsuccessful option
                if (error?.description.contains("offline"))! {
                    completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForLogin(false, error)
                }
                return
            }
            
            let postSession = data as! [String:AnyObject]
            
            // Set client shared instance's property: sessionID
            let sessionInfo = postSession[ParseClient.UdacityResponseKeys.session] as! [String:AnyObject]
            if let sessionID = sessionInfo[ParseClient.UdacityResponseKeys.id] as? String {
                ParseClient.sharedInstance().sessionID = sessionID
            } else {
                completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve info: \(ParseClient.UdacityResponseKeys.id)"]))
            }
            
            // Set client shared instance's property: userID
            let accountInfo = postSession[ParseClient.UdacityResponseKeys.account] as! [String:AnyObject]
            if let userID = accountInfo[ParseClient.UdacityResponseKeys.key] as? String {
                ParseClient.sharedInstance().userID = userID
            } else {
                completionHandlerForLogin(false, NSError(domain: "getSessionAndUserID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve info: \(ParseClient.UdacityResponseKeys.key)"]))
            }
            
            // Launch completion handler with parms for successful option
            completionHandlerForLogin(true, nil)
        })
    }
    
    // MARK: Retrieve User Info
    // Retrieve initial user information: first name and last name
    func getInitialUserInfo(completionHandlerForGetIserInfo: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForGetUserInfo = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/users/\(ParseClient.sharedInstance().userID!)", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetUserInfo, httpHeaderFieldValue: [:], httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForGetIserInfo(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForGetIserInfo(false, error)
                }
                return
            }
            let getUserData = data as! [String:AnyObject]
            
            // Set client shared instance's properties: user first & last names
            let userInfo = getUserData[ParseClient.UdacityUserData.user] as! [String:AnyObject]
            if let userFirstName = userInfo[ParseClient.UdacityUserData.firstName] as? String, let userLastName = userInfo[ParseClient.UdacityUserData.lastName] as? String {
                
                // Make parameteres dictionary. Set lat/long & mediaURL to defaults (will be changed at the next scene)
                let parametersForMyLocation = [ParseClient.ParseResponseKeys.firstName:userFirstName,
                                               ParseClient.ParseResponseKeys.lastName:userLastName,
                                               ParseClient.ParseResponseKeys.latitude:ParseClient.MapViewConstants.defaultLatitude,
                                               ParseClient.ParseResponseKeys.longitude:ParseClient.MapViewConstants.defaultLongitude,
                                               ParseClient.ParseResponseKeys.mediaURL:ParseClient.MapViewConstants.defaultMediaURL] as [String:AnyObject]
                
                // Init Model's 'myLocation' property
                StudentDataSource.sharedInstance.myLocation = StudentLocation(parametersForMyLocation)
                
                completionHandlerForGetIserInfo(true, nil)
            } else {
                completionHandlerForGetIserInfo(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve user info: \(ParseClient.UdacityUserData.firstName), \(ParseClient.UdacityUserData.lastName))"]))
            }
        })
    }
    
    // MARK: Get all Users locations
    // Get a full list of Student Locations
    func getAllStudentLocations(completionHandlerForGetAllStudentLocations: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        // Extensions for URL: limit & order
        let urlForGetAllStudentLocations = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: [ParseClient.Constants.ParseAPILimit:String(ParseClient.Constants.LimitLocations), ParseClient.Constants.ParseAPIOrder: "-\(ParseClient.ParseResponseKeys.updatedAt)"])
        //let urlForGetAllStudentLocations = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: nil)
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetAllStudentLocations, httpHeaderFieldValue: ParseClient.JSONHeaderCommon.jsonHeaderCommonParse, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForGetAllStudentLocations(false, error)
                }
                return
            }
            
            let locationsData = data as! [String:AnyObject]
            guard let arrayOfLocationDicts = locationsData[ParseClient.ParseResponseKeys.results] as? [[String:AnyObject]] else {
                completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could not parse locations data"]))
                return
            }
            
            // Clean the storage array in order to prevent duplications:
            StudentDataSource.sharedInstance.studentLocations = []
            
            // 'location' in the next iteration is either a valid location record (dict [String:AnyObject]) or invalid one
            for location in arrayOfLocationDicts {
                
                // If failable init succeed then append location to the main array, if not (== nil) just skip
                if let studentLocation = StudentLocation(location) {
                    StudentDataSource.sharedInstance.studentLocations.append(studentLocation)
                }
            
            }
            completionHandlerForGetAllStudentLocations(true,nil)
            })
    }
    
    // MARK: Delete a session ID (log out)
    func deleteSessionID(completionHandlerForDeleteSessionID: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForDeleteSessionID = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/session", parameters: [:])
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookiesStorage = HTTPCookieStorage.shared
        for cookie in sharedCookiesStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        var headerParameters = [String:String]()
        if let xsrfCookie  = xsrfCookie {
            headerParameters[ParseClient.JSONHeaderField.xsrfToken] = xsrfCookie.value
        }
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.delete, withURL: urlForDeleteSessionID, httpHeaderFieldValue: headerParameters, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForDeleteSessionID(false, error)
                }
                return
            }
            
            let postSession = data as! [String:AnyObject]
            let sessionInfo = postSession[ParseClient.UdacityResponseKeys.session] as! [String:AnyObject]
            if let sessionID = sessionInfo[ParseClient.UdacityResponseKeys.id] as? String {
                print("DELETED: ", sessionID)
                completionHandlerForDeleteSessionID(true, nil)
            } else {
                completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot delete session ID"]))
            }
        })
    }
    
    // MARK: Post a new location
    func postNewLocation(mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPostNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPostNewLocation = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: nil, parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
        
        let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.exampleUdacityID)\", \"firstName\": \"\(StudentDataSource.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(StudentDataSource.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.post, withURL: urlForPostNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPostNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let objectID = sessionInfo[ParseClient.ParseResponseKeys.objectID] {
                StudentDataSource.sharedInstance.myLocation?.objectID = (objectID as! String)
                completionHandlerForPostNewLocation(true, nil)
            } else {
                completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot post a new location"]))
            }
        })
    }
    
    // MARK: Replace (put) existing location
    func putNewLocation(locationIDToReplace: String, mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPutNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPutNewLocation = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.ParseApiHost, apiPath: ParseClient.Constants.ParseApiPath, withExtension: "/\(locationIDToReplace)", parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
        
        let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.exampleUdacityID)\", \"firstName\": \"\(StudentDataSource.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(StudentDataSource.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.put, withURL: urlForPutNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPutNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let _ = sessionInfo[ParseClient.ParseResponseKeys.updatedAt] {
                completionHandlerForPutNewLocation(true, nil)
            } else {
                completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot replace an existing location"]))
            }
        })
    }
}
