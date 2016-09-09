//
//  StopFacialGameViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 4/4/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit

class StopFacialGameViewController: UIViewController {

    @IBOutlet weak var pointsEarnedMessageLabel: UILabel!
    
    @IBOutlet weak var totalPointsMessageLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
    }
    
    var earnedPoints : Int = 0

    var totalPoints : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 3
        backButton.layer.borderColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0).CGColor
        
        pointsEarnedMessageLabel.text = "You just earned \(earnedPoints) points!"
        
        totalPointsMessageLabel.text = "TOTAL POINTS: \(totalPoints)"
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
