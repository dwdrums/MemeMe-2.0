//
//  ViewController.swift
//  MemeMe 2.0
//
//  Created by Daniel Schallmeiner on 10.02.20.
//  Copyright © 2020 otaxi GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var memeSentFromDetail: Meme?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: 3.0
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        textTop.text = "TOP"
        textBottom.text = "BOTTOM"
        textBottom.defaultTextAttributes = memeTextAttributes
        textTop.defaultTextAttributes = memeTextAttributes
        textTop.textAlignment = .center
        textBottom.textAlignment = .center
        textBottom.delegate = self
        textTop.delegate = self
    
        if let memeFromDetail = memeSentFromDetail as Meme? {
            imageView.image = memeFromDetail.image
            textTop.text = memeFromDetail.top
            textBottom.text = memeFromDetail.bottom
        }
        
        checkForShare()
        checkForCancel()
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        subscribeToKeyboardNotifications()
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        // for testing because sharing not possible currently
        save()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
       let activityItem: [AnyObject] = [generateMemedImage() as AnyObject]
       let activityController = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
       present(activityController, animated: true)
       activityController.completionWithItemsHandler? = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
           if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
           } else {
               return
           }
       }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            checkForCancel()
            checkForShare()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "textBottom" {
            if textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
        if textField.accessibilityIdentifier == "textTop" {
            if textField.text == "TOP" {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField.accessibilityIdentifier == "textBottom" {
                textField.text = "BOTTOM"
            }
            if textField.accessibilityIdentifier == "textTop" {
                textField.text = "TOP"
            }
        }
        checkForShare()
        checkForCancel()
        
    }
    
    func checkForShare() {
        if textTop.text != "TOP" && textBottom.text != "BOTTOM" && imageView.image != nil {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    func checkForCancel() {
        if textTop.text != "TOP" || textBottom.text != "BOTTOM" || imageView.image != nil {
                   cancelButton.isEnabled = true
               } else {
                   cancelButton.isEnabled = false
               }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
            
        let meme = Meme(top: textTop.text!, bottom: textBottom.text!, image: imageView.image!, memedImage: generateMemedImage())
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {

        navbar.isHidden = true
        toolbar.isHidden = true

        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        navbar.isHidden = false
        toolbar.isHidden = false
        
        return memedImage
    }
    
}

