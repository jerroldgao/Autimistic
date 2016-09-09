//
//  ProfileViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/22/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let firebase = Firebase(url: "https://autimisticapp.firebaseio.com/users")
    let doctorRef = Firebase(url: "https://autimisticapp.firebaseio.com/doctors")
    let childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
    
    // MARK: Properties
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var patientID: UILabel!
    @IBOutlet weak var uniqueIDHeader: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var doctorInfoView: UIView!
    @IBOutlet weak var imageTapGestureRecognizer: UITapGestureRecognizer!
    

    var progressID = String()
    
    var userID = String()
    var role = String()
    var email = String()
    var sentEmail : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doctorInfoView.hidden = true
        uniqueIDHeader.hidden = true
        patientID.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.title = "Profile"
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        // Get user info from firebase and update screen
        if sentEmail != nil {
            changePasswordButton.hidden = true
            imageTapGestureRecognizer.enabled = false
            email = sentEmail
            userEmail.text = email
            fillValuesForUser("children", hasUniqueID: true)

            findDoctor(sentEmail)
            sentEmail = nil
        }
        else {
            changePasswordButton.hidden = false
            imageTapGestureRecognizer.enabled = true
            firebase.childByAppendingPath(firebase.authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                self.userEmail.text = (snapshot.childSnapshotForPath("email").value as! String)
                self.email = self.userEmail.text!
                self.role = snapshot.childSnapshotForPath("role").value as! String
                self.findDoctor(snapshot.childSnapshotForPath("email").value as! String)
                if self.role == "Parent" {
                    self.fillValuesForUser("parents", hasUniqueID: false)
                }
                else if self.role == "Patient" {
                    self.fillValuesForUser("children", hasUniqueID: true)
                    self.uniqueIDHeader.hidden = false
                    self.patientID.hidden = false
                }
                else if self.role == "Doctor" {
                    self.fillValuesForUser("doctors", hasUniqueID: false)
                }
                else {
                    // App is broken...
                }
            })
        }
        
        // Circularize userPhoto
        makePhotoCircular(userPhoto)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Stuff to do when view appears
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Generate 8-character ID with characters in A-Z and 0-9
    // NOTE: Will not be used, but kept for legacy purposes
    func generateRandomUUID(len: Int) -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let charArray = Array(chars.characters)
        var randomID = ""
        for _ in 0..<len {
            randomID.append(charArray[Int(arc4random()) % charArray.count])
        }
        
        return randomID
    }
    
    func fillValuesForUser(type: String, hasUniqueID: Bool) {
        let ref = Firebase(url: "https://autimisticapp.firebaseio.com/\(type)")
        ref.queryOrderedByChild("email").queryEqualToValue(email).observeEventType(.ChildAdded, withBlock: { snapshot in
            self.userName.text = (snapshot.value["name"] as! String)
            
            let base64String = snapshot.value["profileImage"] as! String
            let data = NSData(base64EncodedString: base64String, options: [])
            let decodedImage = UIImage(data: data!, scale: 0.1)
            self.userPhoto.image = decodedImage
            
            if hasUniqueID {
                self.patientID.text = (snapshot.value["progressID"] as! String)
                if self.sentEmail != nil{
                    self.patientID.hidden = true
                }
            }
        })
    }
    
    func updateUserPhoto(type: String, base64Photo: String) {
        let ref = Firebase(url: "https://autimisticapp.firebaseio.com/\(type)")
        ref.queryOrderedByChild("email").queryEqualToValue(email).observeEventType(.ChildAdded, withBlock: { snapshot in
            ref.childByAppendingPath(snapshot.key).updateChildValues(["profileImage": base64Photo])
            self.fillValuesForUser(type, hasUniqueID: false)
        })
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Set new user photo and dismiss image picker
        userPhoto.image = image
        var data: NSData = NSData()
        data = UIImageJPEGRepresentation(image, 0.1)!
        let base64String = data.base64EncodedStringWithOptions([])
        
        firebase.childByAppendingPath(firebase.authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if self.role == "Parent" {
                self.updateUserPhoto("parents", base64Photo: base64String)
            }
            else if self.role == "Patient" {
                self.updateUserPhoto("children", base64Photo: base64String)
            }
            else if self.role == "Doctor" {
                self.updateUserPhoto("doctors", base64Photo: base64String)
            }
            else {
                // The app is broken...
            }
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss image picker if user cancels
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func makePhotoCircular(photo: UIImageView) {
        photo.layer.cornerRadius = self.userPhoto.frame.size.width / 2
        photo.clipsToBounds = true
        photo.layer.borderWidth = 3.0
        photo.layer.borderColor = UIColor(red: 0/255, green: 255/255, blue: 128/255, alpha: 1.0).CGColor
    }
    
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        
        // Notify view controller that image has been chosen
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func changePassword(sender: UIButton) {
        var oldPassword: UITextField?
        var newPassword: UITextField?
        let passwordChangeController = UIAlertController(title: "Change Password", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in
        })
        passwordChangeController.addAction(cancelAction)
        let changePassword = UIAlertAction(title: "Submit", style: .Default, handler: {(action) -> Void in
            self.firebase.changePasswordForUser(self.userEmail.text, fromOld: oldPassword?.text, toNew: newPassword?.text, withCompletionBlock: { error in
                // TODO
            })
        })
        passwordChangeController.addAction(changePassword)
        
        passwordChangeController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            oldPassword = textField
            oldPassword?.placeholder = "old password"
            oldPassword?.secureTextEntry = true
        })
        passwordChangeController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            newPassword = textField
            newPassword?.placeholder = "new password"
            newPassword?.secureTextEntry = true
        })
        presentViewController(passwordChangeController, animated: true, completion: nil)
    }
    
    func findDoctor (email: String){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        self.childRef.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
            if snapshot.value["verified"] as! String == "true" {
                let doctorEmail = snapshot.value["doctorEmail"] as! String
                print(snapshot)
                self.doctorRef.queryOrderedByChild("email").queryEqualToValue(doctorEmail).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                    self.doctorName.text = snapshot.value["name"] as! String
                    
                    
                        let imageData = NSData(base64EncodedString: snapshot.value["profileImage"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                        dispatch_async(dispatch_get_main_queue()) {
                            self.doctorImage.image = UIImage(data: imageData, scale: 0.1)
                            self.view.addSubview(self.doctorInfoView)
                        }
                    
                })
            }
        })
        }
        
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
