//
//  PatientProgressViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/18/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//  Edited by Yiru Gao from 2/25/16
//

import Firebase
import UIKit

class PatientProgressViewController: UIViewController {
    let games = ["Facial Emotion Game", "Complex Language Game", "Focus Game"]
    let gameCriteria = ["Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise"]
    
    @IBAction func facialProgressTapped(sender: AnyObject) {
        performSegueWithIdentifier("ProgressToFacialProgress", sender: self)
    }
    
    @IBAction func complexLanguageProgressTapped(sender: AnyObject) {
        performSegueWithIdentifier("ProgressToComplexLanguageProgress", sender: self)
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let addContentAction = UIAlertAction(title: "Add Game Content", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("ProgressToAddContent", sender: self)
        })
        
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        // 4
        optionMenu.addAction(addContentAction)
        
        if (!isDoctor) {
            let addDoctorAction = UIAlertAction(title: "Add Doctor", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("ProgressToAddDoctor", sender: self)
            })
            
            optionMenu.addAction(addDoctorAction)
        }
        
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    var selectedProgressID = String()
    
    var isDoctor = false
    
    let ref = Firebase(url:"https://autimisticapp.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.observeAuthEventWithBlock { (authData) in
            if (authData != nil) {
                let userRef = self.ref.childByAppendingPath("users/\(authData.uid)")
                
                userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if (snapshot.value["role"] as! String == "Doctor") {
                        self.isDoctor = true
                        self.navigationItem.rightBarButtonItem = nil
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Progress"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ProgressToFacialProgress") {
            let destinationVC = segue.destinationViewController as! FacialGameProgressViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        } else if (segue.identifier == "ProgressToComplexLanguageProgress") {
            let destinationVC = segue.destinationViewController as! ComplexLanguageGameProgressViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        } else if (segue.identifier == "ProgressToAddContent") {
            let destinationVC = segue.destinationViewController as! ParentAddContentViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        } else if (segue.identifier == "ProgressToAddDoctor") {
            let destinationVC = segue.destinationViewController as! ParentAddDoctorViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        }
    }
    
}
