//
//  DoctorChildListViewController.swift
//  Autimistic
//
//  Created by Yiru Gao on 4/23/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class DoctorChildListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    @IBOutlet weak var listTableView: UITableView!
    var notification = [String]()
    var names = [String]()
    var emails = [String]()
    var avatars = [String]()
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
        //initial the table view
        self.listTableView.backgroundColor = FlatBlack()
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyle.None

    }
    
    
    //update the information of User. if app is offline, it will read last value
    override func viewWillAppear(animated: Bool) {
        progressIDs.removeAll()
        names.removeAll()
        avatars.removeAll()
        imageData.removeAll()
        emails.removeAll()
        self.tabBarController?.navigationItem.title = "Children"

        if self.ref.authData == nil{
            
        } else {
            let uid = self.ref.authData.uid
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.userRef.childByAppendingPath(uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                    // if the user is doctor
                    
                    let readChildList = self.userRef.childByAppendingPath("\(uid)").observeEventType(.Value, withBlock: {snapshot in
                        self.doctorEmail = snapshot.value["email"] as! String
                        
                        self.childRef.queryOrderedByChild("doctorEmail").queryEqualToValue(self.doctorEmail).observeEventType(.ChildAdded, withBlock: {snapshot in
                            
                            if snapshot.value is NSNull{
                                
                            }else{
                                //check verification
                                if snapshot.value?["verified"] as! String == "true"{
                                    
                                    self.progressIDs.append(snapshot.value["progressID"] as! String)
                                    self.names.append(snapshot.value["name"] as! String)
                                    self.emails.append(snapshot.value["email"] as! String)
                                    self.imageData.append(NSData(base64EncodedString: snapshot.value["profileImage"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)
                                    dispatch_async(dispatch_get_main_queue()) {
                                        // update UI
                                        self.listTableView.reloadData()
                                    }
                                }
                            }
                            
                            
                        })
                    })
                                        self.userRef.removeObserverWithHandle(readChildList)
                    
                    //if the user is parent
                    self.listTableView.tableFooterView = UIView()
                })
                
            }
            
        }

            }
    
    override func viewDidAppear(animated: Bool) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.notification.removeAll()
            self.userRef.childByAppendingPath(self.ref.authData.uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                //if the user is doctor
            
                    
                    self.userRef.childByAppendingPath(self.ref.authData.uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                        self.doctorEmail = snapshot.value["email"] as! String
                    })
                    self.childRef.queryOrderedByChild("doctorEmail").queryEqualToValue(self.doctorEmail).observeEventType(.ChildAdded, withBlock: {snapshot in
                        //check verification
                        if snapshot.value["verified"] as! String == "false"{
                            self.notification.append(snapshot.value["progressID"] as! String)
                        }
                        if self.notification.count > 0{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tabBarController?.tabBar.items?[1].badgeValue = String(self.notification.count)
                            }
                            
                        }else{
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tabBarController?.tabBar.items?[1].badgeValue = nil
                            }
                        
                        }
                    })
                
            })
        
        }
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = tableView.dequeueReusableCellWithIdentifier("DoctorChildListCell", forIndexPath: indexPath) as! DoctorChildListTableViewCell
        //        cell.avatar = self.avatar[indexPath.row]
        cell.name.text = self.names[indexPath.row]
        cell.progressID.text = self.progressIDs[indexPath.row]
        cell.email = self.emails[indexPath.row]
        cell.imageButton.tag = indexPath.row
        cell.imageButton.addTarget(self, action: #selector(DoctorChildListViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        cell.avatar.image = UIImage(data: self.imageData[indexPath.row], scale: 0.1)
        
        
        //        let tapImageGesture = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        //        cell.avatar.addGestureRecognizer(tapImageGesture)
        //        cell.avatar.userInteractionEnabled = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedProgressID = progressIDs[indexPath.row]
        performSegueWithIdentifier("DoctorChildListToProgress", sender: self)
    }
    
    
    //The function works for table side bar
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
                            self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.progressIDs[indexPath.row]).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                                self.childRef.childByAppendingPath(snapshot.key).childByAppendingPath("doctorEmail").setValue("")
                                self.childRef.childByAppendingPath(snapshot.key).childByAppendingPath("verified").setValue("")
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
        performSegueWithIdentifier("DoctorChildListToProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DoctorChildListToProfile"
        {
            let destinationVC = segue.destinationViewController as! ProfileViewController
            destinationVC.sentEmail = selectedEmail
        } else if segue.identifier == "DoctorChildListToProgress" {
            let destinationVC = segue.destinationViewController as! PatientProgressViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


