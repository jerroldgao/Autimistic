//
//  ParentAddFacialContentViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 3/5/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase

class ParentAddFacialContentViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref = Firebase(url: "https://autimisticapp.firebaseio.com/")
    
    var selectedProgressID : String!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    @IBOutlet weak var emotionPicker: UIPickerView!
    
    @IBOutlet weak var submitButton: UIButton!
    
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
        choosePhotoButton.layer.borderWidth = 0
        
        photoImageView.image = image
        photoImageView.layer.zPosition = 1
    }
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        let uploadImage = photoImageView.image
        
        if (uploadImage == nil) {
            let alert = UIAlertController(title: "Oops...", message: "You must choose a photo for this question", preferredStyle:UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let imageData: NSData = UIImageJPEGRepresentation(uploadImage!, 0.8)!
            
            let imageString = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            let gameRef = ref.childByAppendingPath("games/facial")
            
            let userQuestionRef = gameRef.childByAutoId()
            
            let correctAnswer = emotionPicker.selectedRowInComponent(0)
            
            gameRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                var data = ["image": "\(imageString)", "correctAnswer": correctAnswer, "index": snapshot.childrenCount]
                
                if (self.selectedProgressID != nil) {
                    data = ["image": "\(imageString)", "correctAnswer": correctAnswer, "index": snapshot.childrenCount, "to": "\(self.selectedProgressID)"]
                }
                
                userQuestionRef.setValue(data, withCompletionBlock: { (error, firebase) in
                    if (error == nil) {
                        SweetAlert().showAlert("Success!", subTitle: "New Facial Recognition content added", style: .Success, buttonTitle: "Back to Child List", buttonColor: UIColor.greenColor(), action: { (isOtherButton) in
                            let parentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ParentNavigation")
                            self.presentViewController(parentViewController, animated: true, completion: nil)
                        })
                    }
                })
            })
        }
    }
    
    let emotionData = ["Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        choosePhotoButton.layer.borderWidth = 3.0
        choosePhotoButton.layer.borderColor = UIColor.grayColor().CGColor
        choosePhotoButton.layer.cornerRadius = 10.0
        
        submitButton.layer.borderWidth = 3.0
        submitButton.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        submitButton.layer.cornerRadius = 5.0
        
        emotionPicker.selectRow(3, inComponent: 0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emotionData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return emotionData[row]
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
