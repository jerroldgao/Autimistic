//
//  ParentAddDoctorViewController.swift
//  Autimistic
//
//  Created by Ryan Brink on 2/25/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

// Query firebase for parents children unique id 
class ParentAddDoctorViewController: UIViewController {
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    //This need to be assigned!
    var selectedProgressID : String!
    
    let userRef = Firebase(url: "https://autimisticapp.firebaseio.com/users")
    let childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
    let docRef = Firebase(url: "https://autimisticapp.firebaseio.com/doctors")
    var doctorPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        submitButton.layer.borderWidth = 3.0
        submitButton.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        submitButton.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(animated: Bool) {
        ///
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Add Doctor"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendNotification(sender: AnyObject) {
        if userRef.authData != nil {
            if self.emailAddress.text!.isEmpty {
                SweetAlert().showAlert("Oops...", subTitle: "Please add your child ID", style: AlertStyle.Warning)
            } else {
                self.docRef.queryOrderedByChild("email").queryEqualToValue(self.emailAddress.text!).observeSingleEventOfType(.Value, withBlock: {snapshot in
                    if snapshot.value is NSNull{
                        SweetAlert().showAlert("Opps...", subTitle: "This doctor do not have a Autimistic account, suggest it to your doctor!", style: AlertStyle.Error)
                    }else{
                        self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.selectedProgressID).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                            
                            if snapshot.hasChild("doctorEmail"){
                                if (snapshot.value["doctorEmail"] as! String) == self.emailAddress.text!{
                                    SweetAlert().showAlert("Hey", subTitle: "This is the current doctor", style: AlertStyle.Warning)
                                }else{
                                    SweetAlert().showAlert("Double Check", subTitle: "Your child has a Doctor right now, do you really want to switch a doctor?", style: AlertStyle.Warning, buttonTitle: "No", buttonColor: FlatRed(), otherButtonTitle: "Yes, I do want to change", otherButtonColor: FlatGreen(), action: { (isOtherButton) -> Void in
                                        if isOtherButton == false {
                                            self.childRef.childByAppendingPath(snapshot.key).updateChildValues(["verified":"false"])
                                            self.childRef.childByAppendingPath(snapshot.key).updateChildValues(["doctorEmail":self.emailAddress.text!])
                                            
                                        }
                                    })
                                }
                                
                                
                                
                            } else {
                                self.childRef.childByAppendingPath(snapshot.key).updateChildValues(["doctorEmail":self.emailAddress.text!])
                                self.childRef.childByAppendingPath(snapshot.key).updateChildValues(["verified":"false"])
                                SweetAlert().showAlert("Great!", subTitle: "Your child has been assigned a doctor", style: AlertStyle.Success)
                            }
                        })
                    }
                })
                
                
                
                
            }
        }else{
            //handling user expired.
        }
    }


}
