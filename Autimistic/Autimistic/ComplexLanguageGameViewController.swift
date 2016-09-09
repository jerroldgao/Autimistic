//
//  ComplexLanguageGameViewController.swift
//  Autimistic
//
//  Created by Ryan Brink on 4/4/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation

class ComplexLanguageGameViewController: UIViewController {

    let ref = Firebase(url: "https://autimisticapp.firebaseio.com")
    
    // MARK: - Properties
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var timer = NSTimer()
    var counter = 20
    var videoPlayer = AVPlayer()
    var playerViewController = AVPlayerViewController()
    
    var questionIndex = 0
    var questionIndices = [String]()
    var currentQuestionType = ""
    var currentQuestionAnswer = ""
    
    var questionsRemaining = 3
    
    var currentStreak = 0
    var points = 0
    var longestStreak = 0
    var numCorrectHyperboleAnswers = 0
    var numCorrectPunAnswers = 0
    var numCorrectSarcasmAnswers = 0
    var numHyperboleAnswers = 0
    var numPunAnswers = 0
    var numSarcasmAnswers = 0
    var numCorrectAnswers = 0
    var numIncorrectAnswers = 0
    var numNoAnswers = 0
    var numTotalAnswers = 0
    var totalAnswerTime = 0
    var totalPoints = 0
    
    
    var progressID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true

        // Do any additional setup after loading the view.
        timerLabel.text = String(counter)
        
        let uid = ref.authData.uid as NSString
        let index = uid.length - 8
        progressID = uid.substringFromIndex(index)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height: videoView.frame.height)
        playerViewController.showsPlaybackControls = false
        videoView.addSubview(playerViewController.view)
        
        getCurrentProgressValues()
        startCountDown()
        loadFirstQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func endGame(sender: UIButton) {
        videoPlayer.pause()
        stopCountDown()
    }
    
    @IBAction func yesButtonPressed(sender: UIButton) {
        stopCountDown()
        
        if currentQuestionAnswer == "yes" {
            updateProgressForCorrectAnswer()
        } else {
            updateProgressForIncorrectAnswer()
        }
        
        nextQuestion()
    }
    
    @IBAction func noButtonPressed(sender: UIButton) {
        stopCountDown()
        
        if currentQuestionAnswer == "no" {
            updateProgressForCorrectAnswer()
        } else {
            updateProgressForIncorrectAnswer()
        }
        
        nextQuestion()
    }
    
    func updateProgressForCorrectAnswer() {
        getCurrentProgressValues()
        
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        if currentQuestionType == "hyperbole" {
            numCorrectHyperboleAnswers += 1
            numHyperboleAnswers += 1
        } else if currentQuestionType == "pun" {
            numCorrectPunAnswers += 1
            numPunAnswers += 1
        } else if currentQuestionType == "sarcasm" {
            numCorrectSarcasmAnswers += 1
            numSarcasmAnswers += 1
        }
        numCorrectAnswers += 1
        numTotalAnswers += 1
        totalAnswerTime += 20-counter
        totalPoints += 1
        points += 1
        
        updateProgressValues()
    }
    
    func updateProgressForIncorrectAnswer() {
        getCurrentProgressValues()
        
        currentStreak = 0
        if currentQuestionType == "hyperbole" {
            numHyperboleAnswers += 1
        } else if currentQuestionType == "pun" {
            numPunAnswers += 1
        } else if currentQuestionType == "sarcasm" {
            numSarcasmAnswers += 1
        }
        numIncorrectAnswers += 1
        numTotalAnswers += 1
        totalAnswerTime += 20-counter
        
        updateProgressValues()
    }
    
    func updateProgressForMissedAnswer() {
        getCurrentProgressValues()
        
        currentStreak = 0
        if currentQuestionType == "hyperbole" {
            numHyperboleAnswers += 1
        } else if currentQuestionType == "pun" {
            numPunAnswers += 1
        } else if currentQuestionType == "sarcasm" {
            numSarcasmAnswers += 1
        }
        numNoAnswers += 1
        numTotalAnswers += 1
        totalAnswerTime += 20
        
        updateProgressValues()
    }
    
    func getCurrentProgressValues() {
        let progressRef = self.ref.childByAppendingPath("/progress/\(progressID)/complex")
        
        progressRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.longestStreak = snapshot.childSnapshotForPath("longestStreak").value as! Int
            self.numCorrectHyperboleAnswers = snapshot.childSnapshotForPath("numCorrectHyperboleAnswers").value as! Int
            self.numCorrectPunAnswers = snapshot.childSnapshotForPath("numCorrectPunAnswers").value as! Int
            self.numCorrectSarcasmAnswers = snapshot.childSnapshotForPath("numCorrectSarcasmAnswers").value as! Int
            self.numHyperboleAnswers = snapshot.childSnapshotForPath("numHyperboleAnswers").value as! Int
            self.numPunAnswers = snapshot.childSnapshotForPath("numPunAnswers").value as! Int
            self.numSarcasmAnswers = snapshot.childSnapshotForPath("numSarcasmAnswers").value as! Int
            self.numCorrectAnswers = snapshot.childSnapshotForPath("numCorrectAnswers").value as! Int
            self.numIncorrectAnswers = snapshot.childSnapshotForPath("numIncorrectAnswers").value as! Int
            self.numNoAnswers = snapshot.childSnapshotForPath("numNoAnswers").value as! Int
            self.numTotalAnswers = snapshot.childSnapshotForPath("numTotalAnswers").value as! Int
            self.totalAnswerTime = snapshot.childSnapshotForPath("totalAnswerTime").value as! Int
            self.totalPoints = snapshot.childSnapshotForPath("totalPoints").value as! Int
        })
    }
    
    func updateProgressValues() {
        let progressRef = self.ref.childByAppendingPath("/progress/\(progressID)/complex")
        
        progressRef.updateChildValues(["longestStreak": longestStreak, "numCorrectHyperboleAnswers": numCorrectHyperboleAnswers, "numHyperboleAnswers": numHyperboleAnswers, "numCorrectPunAnswers": numCorrectPunAnswers, "numPunAnswers": numPunAnswers, "numCorrectSarcasmAnswers": numCorrectSarcasmAnswers, "numSarcasmAnswers": numSarcasmAnswers, "numCorrectAnswers": numCorrectAnswers, "numIncorrectAnswers": numIncorrectAnswers, "numNoAnswers": numNoAnswers, "numTotalAnswers": numTotalAnswers, "totalAnswerTime": totalAnswerTime, "totalPoints": totalPoints])
    }
    
    
    func loadFirstQuestion() {
        ref.childByAppendingPath("/games/complex").observeSingleEventOfType(.Value, withBlock: { snapshot in
            var indices = [String]()
            for child in snapshot.children {
                indices.append(child.key)
            }
            self.questionIndices = indices
            
            self.nextQuestion()
        })
    }
    
    func nextQuestion() {
        noButton.enabled = false
        noButton.alpha = 0.4
        yesButton.enabled = false
        yesButton.alpha = 0.4
        
        if questionsRemaining == 0 {
            stopButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            return
        }
        questionsRemaining -= 1
        questionIndex = Int(arc4random_uniform(UInt32(questionIndices.count)))
        let fbIndex = questionIndices[questionIndex]
        questionIndices.removeAtIndex(questionIndex)
        
        let questionRef = self.ref.childByAppendingPath("/games/complex/\(fbIndex)")
        
        questionRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.questionLabel.text = snapshot.childSnapshotForPath("question").value as? String
            self.currentQuestionType = snapshot.childSnapshotForPath("type").value as! String
            self.currentQuestionAnswer = snapshot.childSnapshotForPath("answer").value as! String
        })
        
        playVideo(fbIndex)
        startCountDown()
    }
    
    func playVideo(index: String) {
        let videoPath = NSBundle.mainBundle().pathForResource("complexgame_\(index)", ofType: "mp4")
        if let path = videoPath {
            let url = NSURL.fileURLWithPath(path)
            videoPlayer = AVPlayer(URL: url)
            playerViewController.player = videoPlayer
            videoPlayer.play()
        }
    }
    
    
    
    func startCountDown() {
        stopCountDown()
        
        counter = 20
        timerLabel.text = String(counter)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ComplexLanguageGameViewController.updateCounter), userInfo: nil, repeats: true)
    }
    
    func stopCountDown() {
        timer.invalidate()
    }
    
    func updateCounter() {
        if videoPlayer.rate == 0.0 {
            noButton.alpha = 1.0
            noButton.enabled = true
            yesButton.alpha = 1.0
            yesButton.enabled = true
            counter -= 1
        }
        
        timerLabel.text = String(counter)
        
        if counter == 0 {
            stopCountDown()
            
            updateProgressForMissedAnswer()
            
            nextQuestion()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController as! StopFacialGameViewController
        destination.earnedPoints = points
        destination.totalPoints = totalPoints
    }

}
