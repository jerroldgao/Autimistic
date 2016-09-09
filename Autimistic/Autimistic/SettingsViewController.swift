//
//  SettingsViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/22/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    let ref = Firebase(url:"https://autimisticapp.firebaseio.com")
    let childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
    let docRef = Firebase(url: "https://autimisticapp.firebaseio.com/doctors")
    let progressRef = Firebase(url: "https://autimisticapp.firebaseio.com/progress")
    let userRef = Firebase(url: "https://autimisticapp.firebaseio.com/users")
    let gameRef = Firebase(url: "https://autimisticapp.firebaseio.com/games")
    let parentRef = Firebase(url: "https://autimisticapp.firebaseio.com/parents")

    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        SweetAlert().showAlert("Are you sure?", subTitle: "You will be logged out", style: AlertStyle.Warning, buttonTitle:"No", buttonColor: UIColor.grayColor() , otherButtonTitle:  "Yes", otherButtonColor: UIColor.grayColor()) { (isOtherButton) -> Void in
            if (!isOtherButton) {
                self.ref.unauth()
                self.childRef.unauth()
                self.userRef.unauth()
                self.docRef.unauth()
                self.progressRef.unauth()
                self.gameRef.unauth()
                self.progressRef.unauth()
                let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                
                self.presentViewController(patientViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logoutButton.layer.borderWidth = 3.0
        logoutButton.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        logoutButton.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Settings"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
