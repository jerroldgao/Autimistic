//
//  PatientGameMenuViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 2/17/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit

class PatientGameMenuViewController: UIViewController {
    
    let games = ["Facial Emotion Game", "Complex Language Game", "Focus Game"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Games"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
