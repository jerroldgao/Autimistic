////
////  ViewController.swift
////  Autimistic
////
////  Created by Darrall Flowers on 4/20/16.
////  Copyright © 2016 Swift by Example. All rights reserved.
////
//import UIKit
//
//enum Difficulty {
//    case BEGINNER, ADVANCED, INTERMEDIATE
//}
//
//class ViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setup()
//    }
//}
//
//private extension ViewController {
//    func setup() {
//        view.backgroundColor = UIColor.blueColor()
//        
//        buildSelectorCenter(CGPoint(x: view.center.x, y: view.center.y/2.0),
//            title: "BEGINNER", color: UIColor.greenColor(), action: #selector(ViewController.onBEGINNERTapped(_:)))
//        
//        buildSelectorCenter(CGPoint(x: view.center.x, y: view.center.y),
//            title: "ADVANCED", color: UIColor.yellowColor(), action: #selector(ViewController.onADVANCEDTapped(_:)))
//        
//        buildSelectorCenter(CGPoint(x: view.center.x, y: view.center.y*3.0/2.0),
//            title: "INTERMEDIATE", color: UIColor.redColor(), action: #selector(ViewController.onINTERMEDIATETapped(_:)))
//    }
//
//    func buildSelectorCenter(center: CGPoint, title: String, color: UIColor, action: Selector) {
//        
//        let selector = UIButton()
//        selector.setTitle(title, forState: .Normal)
//        selector.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 50))
//        selector.center = center
//        selector.backgroundColor = color
//        selector.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(selector)
//    }
//}
//
//extension ViewController {
//    func onBEGINNERTapped(sender: UIButton) {
//        GameDifficulty(.BEGINNER)
//    }
//    
//    func onADVANCEDTapped(sender: UIButton) {
//        GameDifficulty(.ADVANCED)
//    }
//    
//    func onINTERMEDIATETapped(sender: UIButton) {
//        GameDifficulty(.INTERMEDIATE)
//    }
//    
//    func GameDifficulty(difficulty: Difficulty) {
//        print(" check ")
//        let gameViewController = FocusGameViewController(difficulty: difficulty)
//        presentViewController(gameViewController, animated: true, completion: nil)
//    }
//}
//
//
