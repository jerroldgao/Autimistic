////
////  ParentAddChildViewController.swift
////  Autimistic
////
////  Created by Ryan Brink on 2/25/16.
////  Copyright © 2016 CS309_G27_iastate. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class ParentAddChildViewController: UIViewController {
//
//    var userRef = Firebase(url: "https://autimisticapp.firebaseio.com/users")
//    var childRef = Firebase(url: "https://autimisticapp.firebaseio.com/children")
//    
//    @IBOutlet weak var childID: UITextField!
//    var childName = String()
//    var imageData = String()
//    var progressID = String()
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        self.tabBarController?.navigationItem.hidesBackButton = true
//        self.tabBarController?.navigationItem.title = "Add Child"
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    //This is the textfield for adding Progress ID of Child
//    
//    
//
//
//    @IBAction func addChildCellButton(sender: AnyObject) {
//        if userRef.authData == nil{
//                SweetAlert().showAlert("Crash", subTitle: "login expired, please relogin the app", style: AlertStyle.Error)
//            }else if self.childID.text!.isEmpty
//            {
//                SweetAlert().showAlert("", subTitle: "You must enter an unique ID of child(It's in child profile)", style: AlertStyle.Error)
//            }else{
//                self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.childID.text).observeSingleEventOfType(.Value, withBlock: {snapshot in
//                    if snapshot.value is NSNull{
//                        SweetAlert().showAlert("",subTitle: "No such child exist", style: AlertStyle.Error)
//                    }else{
//                        self.childRef.queryOrderedByChild("progressID").queryEqualToValue(self.childID.text).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
//                            let child = snapshot.value
//                            self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").childByAppendingPath(snapshot.key).observeSingleEventOfType(.Value, withBlock: {snapshot in
//                                if snapshot.value is NSNull{
//                                    self.userRef.childByAppendingPath(self.userRef.authData.uid).childByAppendingPath("child").childByAppendingPath(snapshot.key).setValue(child)
//                                    SweetAlert().showAlert("Congrats", subTitle: "The child has been added in your list", style: AlertStyle.Success)
//                                }else{
//                                    SweetAlert().showAlert("", subTitle: "The child is in your list", style: AlertStyle.Error)
//                                }
//                            
//                            })
//                            
//                    
//                        })
//                    }
//                })
//                
//                
//                        
//                    
//            
////                self.proRef.childByAppendingPath(self.childID.text).childByAppendingPath("user").observeEventType(.Value, withBlock: {snapshot in
//////                    if (snapshot.childSnapshotForPath("profileImage").value != nil) {
//////                        self.imageData = snapshot.childSnapshotForPath("profileImage").value as! String
//////                    }
////                    if snapshot.childSnapshotForPath("name").value != nil {
////                        self.childName = snapshot.childSnapshotForPath("name").value as! String
////                        
////                        let newCellData = [
////                            "name": self.childName,
////                            "progressID": self.childID.text!,
////                            //                    "profileImage": self.imageData
////                        ]
////                        
////                        self.ref.childByAppendingPath(self.ref.authData.uid).childByAppendingPath("childProgress").childByAutoId().setValue(newCellData)
////                    }
////                    }
////                )
//                
//                
//            
//        }
//        
//    }
//    
//    
//    
//
//   
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
