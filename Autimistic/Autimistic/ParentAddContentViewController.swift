//
//  ParentAddContentViewController.swift
//  Autimistic
//
//  Created by Ryan Brink on 2/24/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit

class ParentAddContentViewController: UIViewController {
    
    let games = ["Facial Emotion Game", "Complex Language Game", "Focus Game"]
    
    var selectedProgressID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.title = "Add Content"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "AddContentToAddFacialContent") {
            let destinationVC = segue.destinationViewController as! ParentAddFacialContentViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        }
    }

}
