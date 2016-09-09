////
////  DoctorProgressViewController.swift
////  Autimistic
////
////  Created by Quan K. Huynh on 2/22/16.
////  Copyright © 2016 CS309_G27_iastate. All rights reserved.
////
//
//import UIKit
//
//class DoctorProgressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var progressTableView: UITableView!
//    
//    let games = ["Facial Emotion Game", "Complex Language Game", "Focus Game"]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        self.tabBarController?.navigationItem.hidesBackButton = true
//        self.tabBarController?.navigationItem.title = "Progress"
//        
//        progressTableView.reloadData()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return games.count
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 70;
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("DoctorProgressCell", forIndexPath: indexPath) as! DoctorProgressTableViewCell
//        
//        cell.gamePhoto.image = UIImage(named: "defaultphoto_960.png")
//        cell.gameNameLabel.text = games[indexPath.row]
//        
//        return cell
//    }
//    
//    // MARK: - Navigation
//    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if (segue.identifier == "ShowDoctorGameProgressSegue") {
//            if let destination = segue.destinationViewController as? DoctorGameProgressViewController {
//                if let gameTableIndex = progressTableView.indexPathForSelectedRow?.row {
////                    destination.gameName = games[gameTableIndex]
////                    
////                    if (games[gameTableIndex] == "Facial Emotion Game") {
////                        destination.criteria = ["Happiness", "Sadness", "Fear", "Anger", "Surprise", "Disgust"]
////                    } else if (games[gameTableIndex] == "Complex Language Game") {
////                        destination.criteria = ["CL1", "CL2", "CL3", "CL4", "CL5", "CL6"]
////                    } else if (games[gameTableIndex] == "Focus Game") {
////                        destination.criteria = ["F1", "F2", "F3", "F4", "F5", "F6"]
////                    }
//                }
//            }
//        }
//    }
//
//}
