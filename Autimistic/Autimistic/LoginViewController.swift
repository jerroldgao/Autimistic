//
//  LoginViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/3/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation

class LoginViewController: UIViewController {
    
    var ref = Firebase(url: "https://autimisticapp.firebaseio.com")
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var Forgotpass: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var videoView: UIView!

    var videoPlayer = AVPlayer()
    var playerViewController = AVPlayerViewController()
    
    override func viewWillAppear(animated: Bool) {
        playerViewController.view.frame = videoView.frame
        playerViewController.showsPlaybackControls = false
        playerViewController.view.userInteractionEnabled = false
        videoView.addSubview(playerViewController.view)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = videoView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        videoView.addSubview(blurEffectView)
        
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem, queue: nil) { notification in
            let startTime = CMTimeMake(5, 100)
            self.videoPlayer.seekToTime(startTime)
            self.videoPlayer.play()
        }
        
        let videoPath = NSBundle.mainBundle().pathForResource("autimistic_login_background", ofType: "mov")
        if let path = videoPath {
            let url = NSURL.fileURLWithPath(path)
            videoPlayer = AVPlayer(URL: url)
            playerViewController.player = videoPlayer
            videoPlayer.play()
            videoPlayer.muted = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        login.layer.borderWidth = 3.0
        login.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        login.layer.cornerRadius = 5.0
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // Sends the user an email with instructions for password reset
    @IBAction func forgotPasswordAction(sender: UIButton) {
        let passwordResetController = UIAlertController(title: "Reset Password", message: "Enter an email below to be sent instructions for resetting the account password.", preferredStyle: .Alert)
        var resetEmail: UITextField?
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) -> Void in
        })
        passwordResetController.addAction(cancelAction)
        let resetPassword = UIAlertAction(title: "Reset", style: .Destructive, handler: {(action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.ref.resetPasswordForUser(resetEmail?.text, withCompletionBlock: { error in
                
                if error != nil {
                    let successController = UIAlertController(title: "Reset Password", message: "There was an error in resetting your password with the specified email.", preferredStyle: .Alert)
                    let okayReturn = UIAlertAction(title: "Okay", style: .Default, handler: {(action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    successController.addAction(okayReturn)
                    self.presentViewController(successController, animated: true, completion: nil)
                } else {
                    let successController = UIAlertController(title: "Reset Password", message: "En email has been sent to \(resetEmail!.text!) with instructions for resetting your password.", preferredStyle: .Alert)
                    let okayReturn = UIAlertAction(title: "Okay", style: .Default, handler: {(action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    successController.addAction(okayReturn)
                    self.presentViewController(successController, animated: true, completion: nil)
                }
            })
        })
        passwordResetController.addAction(resetPassword)
        
        passwordResetController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            resetEmail = textField
            resetEmail?.placeholder = "Email"
            resetEmail?.text = self.email.text
        })
        presentViewController(passwordResetController, animated: true, completion: nil)
    }
    
    // Present sign up page for user
    @IBAction func signUpAction(sender: UIButton) {
        videoPlayer.pause()
        let SignUpViewController = storyboard!.instantiateViewControllerWithIdentifier("SignUpNavigationController")
        presentViewController(SignUpViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        let firebase = Firebase(url: "https://autimisticapp.firebaseio.com/users")
        
        if self.email.text!.isEmpty || self.password.text!.isEmpty {
            let alert = UIAlertController(title: "Oops...", message: "Please complete all fields.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Log the user in
            self.ref.authUser(self.email.text, password: self.password.text) {
                error, authData in
                if error != nil {
                    let alert = UIAlertController(title: "Unable to Authenticate", message: "Make sure your email and password are correct and try again.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    firebase.childByAppendingPath(self.ref.authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        self.videoPlayer.pause()
                        self.checkRoleThenNavigate(snapshot.childSnapshotForPath("role").value as! String)
                    })
                }
            }
        }
    }
    
    func checkRoleThenNavigate(role : String) {
        if role.isEqual("Patient") {
            let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
            self.presentViewController(patientViewController, animated: true, completion: nil)
        }
            // Check if user is a patient and if they have a uniqueID... add one if they don't
        else if role.isEqual("Parent") {
            let parentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ParentNavigation")
            self.presentViewController(parentViewController, animated: true, completion: nil)
        }
            // Check if user is a patient and if they have a uniqueID... add one if they don't
        else if role.isEqual("Doctor") {
            let doctorViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DoctorNavigation")
            self.presentViewController(doctorViewController, animated: true, completion: nil)
        } else {
            SweetAlert().showAlert("Undefined role", subTitle: "...time to contact the devs.", style: .Error, buttonTitle: "Okay", buttonColor: UIColor.grayColor())
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