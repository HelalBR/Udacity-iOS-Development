//
//  ViewController.swift
//  MeMe
//
//  Created by Alan Helal on 26/12/17.
//  Copyright © 2017 Alan Helal. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageViewPicker: UIImageView!
    
    let navbar = UINavigationController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func setTextFields(textField: UITextField, defaultText: String) -> Void {
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -4.0,]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.text = defaultText
        textField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        setTextFields(textField: topTextField, defaultText: "TOP")
        setTextFields(textField: bottomTextField, defaultText: "BOTTOM")
        
        if (imageViewPicker.image == nil) {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func selectImage(source: String) -> Void {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if source == "photoLibrary" {
            imagePicker.sourceType = .photoLibrary
            imagePicker.modalPresentationStyle = .currentContext
        }
        else{
            imagePicker.sourceType = .camera
        }
        
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        selectImage(source: "photoLibrary")
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        selectImage(source: "camera")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageViewPicker.image = image
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewPicker.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save(imageMeme: UIImage) {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewPicker.image!, memedImage: imageMeme)
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
    
    func setNavbarVisibility(visibility: Bool) -> Void {
        navbar.setNavigationBarHidden(visibility, animated: true)
        navbar.setToolbarHidden(visibility, animated: true)
        topToolBar.isHidden = visibility
        bottomToolBar.isHidden = visibility
    }
    
    func setBackgroundColor(color: String) -> Void {
        if color == "white"{
            self.view.backgroundColor = UIColor.white
        }
        else{
            self.view.backgroundColor = UIColor.black
        }
    }
    
    func generateMemedImage() -> UIImage {
        setNavbarVisibility(visibility: true)
        setBackgroundColor(color: "black")
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        setNavbarVisibility(visibility: false)
        setBackgroundColor(color: "white")
        
        return memedImage
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        setTextFields(textField: topTextField, defaultText: "TOP")
        setTextFields(textField: bottomTextField, defaultText: "BOTTOM")
        imageViewPicker.image = nil
        self.view.endEditing(true)
        shareButton.isEnabled = false
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let image = generateMemedImage()
        // let memedImageToShare = [memedImage]
        
        //let activityViewController = UIActivityViewController(activityItems: memedImageToShare, applicationActivities: nil)
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if(success && error == nil){
                self.save(imageMeme: image)
                self.dismiss(animated:true, completion: nil);
            }
            else if (error != nil){
                let alert = UIAlertController(title: "Oooops!", message: "Something went wrong...", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
        };
        
        present(activityViewController, animated: true, completion: nil)
    }
}

