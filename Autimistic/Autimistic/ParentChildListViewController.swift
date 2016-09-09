//
//  ParentChildListViewController.swift
//  Autimistic
//
//  Created by Yiru Gao on 4/4/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ParentChildListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var progressIDTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        if userRef.authData == nil{
            SweetAlert().showAlert("Crash", subTitle: "login expired, please relogin the app", style: AlertStyle.Error)
        } else if progressIDTextField.text!.isEmpty {
            SweetAlert().showAlert("", subTitle: "You must enter an unique ID of child(It's in child profile)", style: AlertStyle.Error)
        } else {
            self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.progressIDTextField.text).observeSingleEventOfType(.Value, withBlock: {snapshot in
                if snapshot.value is NSNull{
                    SweetAlert().showAlert("",subTitle: "No such child exist", style: AlertStyle.Error)
                } else {
                    self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.progressIDTextField.text).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                        let child = snapshot.value
                        
                        self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").childByAppendingPath(snapshot.key).observeSingleEventOfType(.Value, withBlock: {snapshot in
                            if snapshot.value is NSNull {
                                self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").childByAppendingPath(snapshot.key).setValue(child)
                                SweetAlert().showAlert("Congrats", subTitle: "The child has been added in your list", style: AlertStyle.Success)
                            } else {
                                SweetAlert().showAlert("", subTitle: "The child is in your list", style: AlertStyle.Error)
                            }
                        })
                    })
                }
            })
        }
    }
    
    var notification = [String]()
    var names = [String]()
    var emails = [String]()
//    var avatars = [String]()
    var progressIDs = [String]()
    var imageData = [NSData]()
    var doctorEmail = String()
    var selectedProgressID : String!
    
    var selectedEmail : String!
    
    let ref = Firebase(url: "https://autimisticapp.firebaseio.com")
    let userRef = Firebase(url: "https://autimisticapp.firebaseio.com/users")
    let childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressIDTextField.delegate = self
        
        submitButton.layer.borderWidth = 3.0
        submitButton.layer.cornerRadius = 5.0
        submitButton.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        self.listTableView.backgroundColor = FlatBlack()
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyle.None

    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.title = "Children"

        progressIDs.removeAll()
        names.removeAll()
//        avatars.removeAll()
        imageData.removeAll()
        emails.removeAll()
        if ref.authData == nil{
            
        } else {
            let uid = ref.authData.uid
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.userRef.childByAppendingPath(uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                    
                    let readChildParent = self.userRef.childByAppendingPath("\(uid)/child").queryOrderedByChild("name").observeEventType(.ChildAdded, withBlock: {snapshot in
                        if snapshot.value is NSNull{
                            
                        }else{
                            self.childRef.queryOrderedByChild("progressID").queryEqualToValue(snapshot.value["progressID"]).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                                self.progressIDs.append(snapshot.value["progressID"] as! String)
                                self.emails.append(snapshot.value["email"] as! String)
                                self.names.append(snapshot.value["name"] as! String)
                                self.imageData.append(NSData(base64EncodedString: snapshot.value["profileImage"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)
                                dispatch_async(dispatch_get_main_queue()) {
                                    //                                         update some UI
                                    self.listTableView.reloadData()
                                }
                                self.listTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                            })
                        }
                        
                    })
                    self.userRef.removeObserverWithHandle(readChildParent)
                })
                
            }
            
        }

        
        }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParentChildListCell", forIndexPath: indexPath) as! ParentChildListTableViewCell
        //        cell.avatar = self.avatar[indexPath.row]
        cell.name.text = self.names[indexPath.row]
        cell.progressID.text = self.progressIDs[indexPath.row]
        cell.email = self.emails[indexPath.row]
        cell.imageButton.tag = indexPath.row
        cell.imageButton.addTarget(self, action: #selector(ParentChildListViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.avatar.image = UIImage(data: self.imageData[indexPath.row], scale: 0.1)
        
        
        //        let tapImageGesture = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        //        cell.avatar.addGestureRecognizer(tapImageGesture)
        //        cell.avatar.userInteractionEnabled = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedProgressID = progressIDs[indexPath.row]
        
        performSegueWithIdentifier("ChildListToProgress", sender: self)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (action , indexPath ) -> Void in
            //Remove child
            SweetAlert().showAlert("Are you sure?", subTitle: "This child will be removed", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor: FlatRed() , otherButtonTitle:  "Yes, I want to remove!", otherButtonColor:FlatGreen()) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    SweetAlert().showAlert("Cancelled!", subTitle: "Think twice is always good!", style: AlertStyle.Error)
                }
                else {
                    self.names.removeAtIndex(indexPath.row)
                    self.imageData.removeAtIndex(indexPath.row)
                    self.userRef.childByAppendingPath(self.userRef.authData.uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                        
                        self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").queryOrderedByChild("progressID").queryEqualToValue(self.progressIDs[indexPath.row]).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                            self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").childByAppendingPath(snapshot.key).removeValue()
                            self.progressIDs.removeAtIndex(indexPath.row)
                        })
                    })
                    
                    
                    
                    
                    
                    
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    SweetAlert().showAlert("Deleted!", subTitle: "This child has been removed!", style: AlertStyle.Success)
                }
            }
        }
        deleteAction.backgroundColor = FlatRed()
        
        return [deleteAction]
    }
    
    func buttonClicked(sender : UIButton) {
        selectedEmail = emails[sender.tag]
        
        performSegueWithIdentifier("ChildListToProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChildListToProfile"
        {
            let destinationVC = segue.destinationViewController as! ProfileViewController
            destinationVC.sentEmail = selectedEmail
        } else if segue.identifier == "ChildListToProgress" {
            let destinationVC = segue.destinationViewController as! PatientProgressViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        }
    }
    

    
    
}
