//
//  DoctorNotificationsViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/22/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class DoctorNotificationsViewController: UIViewController {

    @IBOutlet weak var notificationTableView: UITableView!
    var name = [String]()
    var avatar = [String]()
    var progressID = [String]()
    var email = String()
    var imageData = [NSData]()
    var doctorPath = String()
    let userRef = Firebase(url: "https://autimisticapp.firebaseio.com/users")
    let childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
    
    override func viewDidLoad() {
        self.notificationTableView.tableFooterView = UIView()
        self.notificationTableView.backgroundColor = FlatBlack()
        self.notificationTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.notificationTableView.allowsSelection = false
    }
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.title = "Notifications"

        name.removeAll()
        avatar.removeAll()
        progressID.removeAll()
        imageData.removeAll()
        if userRef.authData == nil{
            
        }else{
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                // do some task
                self.userRef.childByAppendingPath(self.userRef.authData.uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                    self.email = snapshot.childSnapshotForPath("email").value as! String
                    let readChildList = self.childRef.queryOrderedByChild("doctorEmail").queryEqualToValue(self.email).observeEventType(.ChildAdded, withBlock: {snapshot in
                        if snapshot.value?["verified"] as! String == "false" {
                            self.name.append(snapshot.value["name"] as! String)
                            self.avatar.append(snapshot.value["profileImage"] as! String)
                            self.progressID.append(snapshot.value["progressID"] as! String)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // update some UI
                                self.notificationTableView.reloadData()
                                if self.name.count > 0{
                                    self.tabBarController?.tabBar.items?[1].badgeValue = String(self.name.count)
                                }else{
                                    self.tabBarController?.tabBar.items?[1].badgeValue = nil
                                    
                                }
                            }
                            
                            
                        }
                    })
                    self.childRef.removeObserverWithHandle(readChildList)
                    
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return name.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DoctorNotificationsTableViewCell", forIndexPath: indexPath) as! DoctorNotificationsTableViewCell
        //        cell.notiPhoto = self.avatar[indexPath.row]
        cell.notiLabel.text = self.name[indexPath.row]
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.imageData.append(NSData(base64EncodedString: self.avatar[indexPath.row], options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)
            dispatch_async(dispatch_get_main_queue()) {
                cell.notiPhoto.image = UIImage(data: self.imageData[indexPath.row], scale: 0.1)
            }
        }
        
        
        
        
        return cell
    }
    
    

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)->(UITableViewRowAction, UITableViewRowAction) {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "DELETE"){(UITableViewRowAction,NSIndexPath) -> Void in
            
            print("What u want while Pressed delete")
        }
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "CONFIRM"){(UITableViewRowAction,NSIndexPath) -> Void in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            print("What u want while Pressed Edit")
            
        }
        
        delete.backgroundColor = UIColor.redColor()
        edit.backgroundColor = UIColor.greenColor()
        return (delete, edit)
    }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        //confirmation side button
        let confilmAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Confirm") { (action , indexPath) -> Void in
            
            SweetAlert().showAlert("Are you sure?", subTitle: "This patient will be added to your list", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor: FlatRed() , otherButtonTitle:  "Yes, I want to add!", otherButtonColor:FlatGreen()) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    SweetAlert().showAlert("Cancelled!", subTitle: "Maybe next time!", style: AlertStyle.Error)
                }
                else {
                    self.name.removeAtIndex(indexPath.row)
                    self.imageData.removeAtIndex(indexPath.row)
                    self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.progressID[indexPath.row]).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                        self.childRef.childByAppendingPath(snapshot.key).updateChildValues(["verified":"true"])
                    })
                    self.progressID.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    SweetAlert().showAlert("Accepted!", subTitle: "This patient has been accepted!", style: AlertStyle.Success)
                    if self.name.count > 0{
                        self.tabBarController?.tabBar.items?[1].badgeValue = String(self.name.count)
                    }else{
                        self.tabBarController?.tabBar.items?[1].badgeValue = nil
                        
                    }
                }
            }
        }
        confilmAction.backgroundColor = FlatGreen()
        
        //delete side button
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (action , indexPath ) -> Void in
            
            SweetAlert().showAlert("Are you sure?", subTitle: "This request will be deleted", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor: FlatRed() , otherButtonTitle:  "Yes, disregard this for me!", otherButtonColor:FlatGreen()) { (isOtherButton) -> Void in
            if isOtherButton == true {
                SweetAlert().showAlert("Cancelled!", subTitle: "Think twice is always good!", style: AlertStyle.Error)
            }
            else {
                self.name.removeAtIndex(indexPath.row)
                self.imageData.removeAtIndex(indexPath.row)
                self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.progressID[indexPath.row]).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                    self.childRef.childByAppendingPath(snapshot.key).childByAppendingPath("doctorEmail").setValue("")
                    self.childRef.childByAppendingPath(snapshot.key).childByAppendingPath("verified").setValue("")

                })
                self.progressID.removeAtIndex(indexPath.row)
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                SweetAlert().showAlert("Deleted!", subTitle: "This message has been removed!", style: AlertStyle.Success)
                if self.name.count > 0{
                    self.tabBarController?.tabBar.items?[1].badgeValue = String(self.name.count)
                }else{
                    self.tabBarController?.tabBar.items?[1].badgeValue = nil
                    
                }                }
            }
        }
        deleteAction.backgroundColor = FlatRed()
        
        return [deleteAction,confilmAction]
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
