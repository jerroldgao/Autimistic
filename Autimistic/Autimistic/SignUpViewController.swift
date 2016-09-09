//
//  SignUpViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/3/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref = Firebase(url: "https://autimisticapp.firebaseio.com/")
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    @IBOutlet weak var backToLoginButton: UIBarButtonItem!
    
    @IBAction func backToLoginButtonTapped(sender: UIBarButtonItem) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }

    @IBAction func choosePhotoButtonTapped(sender: AnyObject) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let image = UIImagePickerController()
            
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            image.allowsEditing = true
            
            self.presentViewController(image, animated: true, completion: nil)
            
        })
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let image = UIImagePickerController()
            
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.Camera
            image.allowsEditing = true
            
            self.presentViewController(image, animated: true, completion: nil)
            
        })
        
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        // 4
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(chooseFromLibraryAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        choosePhotoButton.titleLabel!.text = ""
        choosePhotoButton.layer.borderWidth = 3.0
        
        profileImage.image = image
        profileImage.layer.zPosition = 1
    }
    
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var genderAndRolePicker: UIPickerView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
      
            
        if (self.firstName.text!.isEmpty || self.lastName.text!.isEmpty || self.email.text!.isEmpty || self.password.text!.isEmpty) {
            
            SweetAlert().showAlert("Oops...", subTitle: "Please complete all fields", style: AlertStyle.Error, buttonTitle:"Okay", buttonColor:UIColor.grayColor())
            
        } else if (self.password.text!.characters.count < 8 || self.password.text?.characters.count > 20) {
            
            SweetAlert().showAlert("Oops...", subTitle: "Password must have at least 8 and at most 20 characters", style: AlertStyle.Error, buttonTitle:"Okay", buttonColor:UIColor.grayColor())
            
        } else {
            
            self.ref.createUser(self.email.text, password: self.password.text,
                           withValueCompletionBlock: { error, result in
                if (error != nil) {
                    var errMessage = ""
                    
                    if (error.code == 5) {
                        errMessage = "Password must have at least 8 and at most 20 characters"
                    } else if (error.code == -9) {
                        errMessage = "This email has already been registered"
                    } else if (error.code == -5) {
                        errMessage = "This email is invalid"
                    }
                    
                    SweetAlert().showAlert("Oops...", subTitle: errMessage, style: AlertStyle.Error, buttonTitle:"Okay", buttonColor:UIColor.grayColor())
                } else {
                    
                    let uid = result["uid"]! as! String
                    
                    self.getDate(self.datePicker)
                    
                    self.gender = self.genderData[self.genderAndRolePicker.selectedRowInComponent(0)]
                    
                    self.role = self.roleData[self.genderAndRolePicker.selectedRowInComponent(1)]
                    
                    var userInfo = ["email": "\(self.email.text!)", "firstName": "\(self.firstName.text!)",
                                "lastName": "\(self.lastName.text!)", "name": "\(self.firstName.text!) \(self.lastName.text!)", "role": "\(self.role)", "gender": "\(self.gender)",
                                "birthday": "\(self.date)", ]
                    
                    let imageData: NSData = UIImageJPEGRepresentation(self.profileImage.image!, 0.1)!
                    
                    let imageString = imageData.base64EncodedStringWithOptions([])
                    
                    userInfo["profileImage"] = "\(imageString)"
                    
                    let userRef = self.ref.childByAppendingPath("users/\(uid)")

                    if (self.role == "Patient") {
                        let index = uid.characters.count - 8
                        
                        let progressId = (uid as NSString).substringFromIndex(index) as String
                        
                        userInfo["progressID"] = progressId
                        
                        userRef.setValue(userInfo)
                        
                        userInfo["doctorEmail"] = ""
                        
                        userInfo["verified"] = ""
                        
                        let childrenRef = self.ref.childByAppendingPath("children/\(uid)")
                        userInfo["doctorEmail"] = ""
                        userInfo["verified"] = ""
                        childrenRef.updateChildValues(userInfo)
                        
                        let facialProgressRef = self.ref.childByAppendingPath("progress/\(progressId)/facial")
                        
//                        let facialProgressInfo = ["currentQuestionIndex": 0, "incorrectQuestions": "", "longestStreak": 0, "numAngerAnswers": 0, "numCorrectAngerAnswers": 0, "numDisgustAnswers": 0, "numCorrectDisgustAnswers": 0, "numFearAnswers": 0, "numCorrectFearAnswers": 0, "numHappinessAnswers": 0, "numCorrectHappinessAnswers": 0, "numSadnessAnswers": 0, "numCorrectSadnessAnswers": 0, "numSurpriseAnswers": 0, "numCorrectSurpriseAnswers": 0, "numCorrectAnswers": 0, "numIncorrectAnswers": 0, "numNoAnswers": 0, "numTotalAnswers": 0, "totalAnswerTime": 0, "totalPoints": 0]
                        
                        let facialProgressInfo = ["currentQuestionIndex": 0, "incorrectQuestions": "", "longestStreak": 0, "numAngerAnswers": 0, "numCorrectAngerAnswers": 0, "numDisgustAnswers": 0, "numCorrectDisgustAnswers": 0, "numFearAnswers": 0, "numCorrectFearAnswers": 0, "numHappinessAnswers": 0, "numCorrectHappinessAnswers": 0, "numSadnessAnswers": 0, "numCorrectSadnessAnswers": 0, "numSurpriseAnswers": 0, "numCorrectSurpriseAnswers": 0, "numCorrectAnswers": 0, "numIncorrectAnswers": 0, "numNoAnswers": 0]
                        
                        facialProgressRef.setValue(facialProgressInfo)
                        
                        let complexProgressRef = self.ref.childByAppendingPath("progress/\(progressId)/complex")
                        
                        let complexProgressInfo = ["currentQuestionIndex": 0, "incorrectQuestions": "", "longestStreak": 0, "numSarcasmAnswers": 0, "numCorrectSarcasmAnswers": 0, "numHyperboleAnswers": 0, "numCorrectHyperboleAnswers": 0, "numPunAnswers": 0, "numCorrectPunAnswers": 0, "numCorrectAnswers": 0, "numIncorrectAnswers": 0, "numNoAnswers": 0, "numTotalAnswers": 0, "totalAnswerTime": 0, "totalPoints": 0]
                        
                        complexProgressRef.setValue(complexProgressInfo)
                    } else if (self.role == "Doctor") {
                        userRef.setValue(userInfo)
                        
                        let doctorsRef = self.ref.childByAppendingPath("doctors/\(uid)")
                        
                        doctorsRef.setValue(userInfo)
                    } else if (self.role == "Parent") {
                        userRef.setValue(userInfo)
                        
                        let parentsRef = self.ref.childByAppendingPath("parents/\(uid)")
                        
                        parentsRef.setValue(userInfo)
                    }
                    
                    
                  
                    
              
                    
                    self.ref.authUser(self.email.text, password: self.password.text) {
                        error, authData in
                        if error != nil {
                            SweetAlert().showAlert("Unable to Authenticate", subTitle: "Please try again later.", style: AlertStyle.Error, buttonTitle: "Okay")
//                            let alert = UIAlertController(title: "Unable to Authenticate", message: "Please try again later.", preferredStyle: .Alert)
//                            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
//                            self.presentViewController(alert, animated: true, completion: nil)
//                            
//                            SweetAlert().showAlert("Oops...", subTitle: "Something is wrong, we are looking into this. Please try again later.", style: AlertStyle.Error, buttonTitle:"Okay", buttonColor:UIColor.grayColor())
                        } else {
                            //Congrats message
                            SweetAlert().showAlert("Congrats", subTitle: "Enjoy the app", style: AlertStyle.Success, buttonTitle:"I will", buttonColor:FlatGray()) {(isOtherButton) -> Void in
                                if isOtherButton == true {
                            // Check if user is a patient
                            if (self.role == "Patient") {
                                let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                                self.presentViewController(patientViewController, animated: true, completion: nil)
                                
                            }
                            // Check if user is a parent
                            else if (self.role == "Parent") {
                                let parentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ParentNavigation")
                                self.presentViewController(parentViewController, animated: true, completion: nil)
                                
                            }
                            // Check if user is a doctor
                            else if (self.role == "Doctor") {
                                let doctorViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DoctorNavigation")
                                self.presentViewController(doctorViewController, animated: true, completion: nil)
                                
                            } else {
                                SweetAlert().showAlert("Undefined Role", subTitle: "...time to contact the devs.", style: AlertStyle.Error, buttonTitle: "Okay")
                            }
                            
                            }
                        }
                    }
                 
                    }
                }
                            
            })
            
            
            }
            
        
    }
    
    var date = String()
    
    var gender = String()
    
    var role = String()
    
    var genderData = ["Male", "Female"]
    
    var roleData = ["Patient", "Parent", "Doctor"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        profileImage.layer.cornerRadius = 10.0
        profileImage.layer.masksToBounds = true
        
        choosePhotoButton.layer.borderWidth = 3.0
        choosePhotoButton.layer.borderColor = UIColor.grayColor().CGColor
        choosePhotoButton.layer.cornerRadius = 10.0
        
        datePicker.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: 0, toDate: NSDate(), options: [])
        datePicker.backgroundColor = UIColor.lightGrayColor()
        datePicker.setDate(NSDate(), animated: false)
        
        genderAndRolePicker.selectRow(1, inComponent: 1, animated: false)
        
        scrollView.contentSize.height = 900
        
//        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
//        self.profileImage.clipsToBounds = true
//        self.profileImage.layer.borderWidth = 3.0
//        self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        submitButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true);
    }
    
    func getDate(datePicker: UIDatePicker){
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        date = dateFormatter.stringFromDate(datePicker.date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return genderData.count
        } else {
            return roleData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return genderData[row]
        } else {
            return roleData[row]
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
