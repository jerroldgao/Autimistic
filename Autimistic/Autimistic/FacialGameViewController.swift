//
//  FacialGameViewController.swift
//  Autimistic
//
//  Created by Yiru Gao on 3/5/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase

class FacialGameViewController: UIViewController {
    
    @IBOutlet weak var questionImage: UIImageView!
    
    @IBOutlet weak var answerButton1: UIButton!
    
    @IBOutlet weak var answerButton2: UIButton!
    
    @IBOutlet weak var answerButton3: UIButton!
    
    @IBOutlet weak var answerButton4: UIButton!

    @IBAction func tappedAnswerButton1(sender: AnyObject) {
        checkAnswer(sender as! UIButton)
    }
    
    @IBAction func tappedAnswerButton2(sender: AnyObject) {
        checkAnswer(sender as! UIButton)
    }
    
    @IBAction func tappedAnswerButton3(sender: AnyObject) {
        checkAnswer(sender as! UIButton)
    }

    @IBAction func tappedAnswerButton4(sender: AnyObject) {
        checkAnswer(sender as! UIButton)
    }
    
    @IBOutlet weak var encouragementLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var timerBar: UIProgressView!
    
    @IBOutlet weak var gameStatusLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    let ref = Firebase(url:"https://autimisticapp.firebaseio.com")
    
    let answers = ["Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise"]
    
    var timer = NSTimer()
    
    var counter = 20
    
    var correctAnswerIndex : Int!
    
    var nextQuestionIndex : Int!
    
    var questionIndex : Int!
    
    var questionKey : String!
    
    var reloadIncorrectQuestions : Bool = false
    
    var emulator : NSEnumerator!
    
    var incorrectQuestionsString : String!
    
    var incorrectQuestionsArray : [String]!
    
    var correctAnswersCounter : Int = 0
    
    var points : Int = 0
    
    var totalPoints : Int = 0
    
    let unitPoint : Int = 5
    
    var progressId : String!
    
    var authObserver : UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        // Do any additional setup after loading the view.
        encouragementLabel.hidden = true
        gameStatusLabel.hidden = true
        
        timerLabel.text = String(counter)
        timerBar.progressTintColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0)
        timerBar.trackTintColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        
        self.authObserver = ref.observeAuthEventWithBlock { (authData) in
            if (authData != nil) {
                let index = authData.uid.characters.count - 8
                
                self.progressId = (authData.uid as NSString).substringFromIndex(index) as String
                
                self.loadQuestion()
            } else {
                SweetAlert().showAlert("Oops...", subTitle: "Something is wrong. We are looking into it. Please try again later.", style: .Error, buttonTitle: "Back to Games Menu") { (isOtherButton) in
                    let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                    self.presentViewController(patientViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {

    }

    override func viewWillDisappear(animated: Bool) {
        ref.removeObserverWithHandle(authObserver)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadQuestion() {
        let progressRef = self.ref.childByAppendingPath("progress/\(progressId)/facial")
        let questionRef = self.ref.childByAppendingPath("games/facial")
        
        progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            let data = snapshot.value
            
            let index = data["currentQuestionIndex"] as? Int
            
            if (index != nil && index != 0) {
                self.nextQuestionIndex = index! + 1
            } else {
                self.nextQuestionIndex = 0
            }
            
            let tp = data["totalPoints"] as? Int
            
            if (tp != nil) {
                self.totalPoints = tp!
            } else {
                self.totalPoints = 0
            }
            
            if (data["incorrectQuestions"] != nil && data["incorrectQuestions"] as! String != "") {
                self.reloadIncorrectQuestions = true
            }
            
            questionRef.queryOrderedByChild("index").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let tempIndex = self.nextQuestionIndex
                
                if (self.nextQuestionIndex != 0 && Int(snapshot.childrenCount) == self.nextQuestionIndex) {
                    self.nextQuestionIndex = self.nextQuestionIndex - 1
                }
                
                questionRef.queryOrderedByChild("index").queryStartingAtValue(self.nextQuestionIndex).observeSingleEventOfType(.Value, withBlock:{ snapshot in
                    self.nextQuestionIndex = tempIndex
                    
                    if (snapshot.childrenCount > 0) {
                        self.emulator = snapshot.children
                        
                        let child = self.emulator.nextObject()!
                        
                        let to = child.value["to"] as! String
                        
                        if (to == "" || to == self.progressId) {
                            let base64String = child.value["image"] as! String
                            let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                            let decodedImage = UIImage(data: data!, scale: 0.1)
                            self.questionImage.image = decodedImage
                            
                            self.correctAnswerIndex = child.value["correctAnswer"] as! Int
                            
                            self.generateAnswers()
                            
                            self.questionIndex = child.value["index"] as! Int
                            self.questionKey = child.key!
                            
                            self.startCountDown()
                        } else {
                            self.nextQuestion()
                        }
                        
//                        let base64String = child.value["image"] as! String
//                        let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
//                        let decodedImage = UIImage(data: data!, scale: 0.1)
//                        self.questionImage.image = decodedImage
//                        
//                        self.correctAnswerIndex = child.value["correctAnswer"] as! Int
//                        self.generateAnswers()
//                        self.questionIndex = child.value["index"] as! Int
//                        self.questionKey = child.key!
                        
//                        self.startCountDown()
                    } else {
                        self.reloadIncorrectQuestions = true
                        
                        self.loadIncorrectQuestion()
                    }
                    
                    }, withCancelBlock: { error in
                        print(error.description)
                })
            })
        }) { (error) in
            print(error.description)
        }
    }
    
    func loadIncorrectQuestion() {
        let progressRef = self.ref.childByAppendingPath("progress/\(progressId)/facial")
        let questionRef = self.ref.childByAppendingPath("games/facial")
        
        progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            let data = snapshot.value
            
            questionRef.queryOrderedByChild("index").queryStartingAtValue(self.nextQuestionIndex).observeSingleEventOfType(.Value, withBlock:{ snapshot in
                
                if (data["incorrectQuestions"] != nil && data["incorrectQuestions"] as! String != "") {
                    self.reloadIncorrectQuestions = true;
                        
                    self.incorrectQuestionsString = data["incorrectQuestions"] as! String
                        
                    self.incorrectQuestionsArray = self.incorrectQuestionsString.componentsSeparatedByString(" ")
                        
                    if (self.incorrectQuestionsArray.count > 0) {
                        let incorrectQuestionRef = questionRef.childByAppendingPath(self.incorrectQuestionsArray[0])
                            
                        self.incorrectQuestionsArray.removeAtIndex(0)
                            
                        self.incorrectQuestionsString = self.incorrectQuestionsArray.joinWithSeparator(" ")
                        
                        var update = [String:String]()
                            
                        update["incorrectQuestions"] = "\(self.incorrectQuestionsString)"
                            
                        progressRef.updateChildValues(update)
                            
                        incorrectQuestionRef.observeSingleEventOfType(.Value, withBlock: { child in
                            
                            let to = child.value["to"] as! String
                            
                            if (to == "" || to == self.progressId) {
                                let base64String = child.value["image"] as! String
                                let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                                let decodedImage = UIImage(data: data!, scale: 0.1)
                                self.questionImage.image = decodedImage
                                
                                self.correctAnswerIndex = child.value["correctAnswer"] as! Int
                                
                                self.generateAnswers()
                                
                                self.questionIndex = child.value["index"] as! Int
                                self.questionKey = child.key!
                                
                                self.startCountDown()
                            } else {
                                self.nextQuestion()
                            }
                            
//                            let base64String = child.childSnapshotForPath("image").value as! String
//                            let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
//                            let decodedImage = UIImage(data: data!, scale: 0.1)
//                            self.questionImage.image = decodedImage
//                            
//                            self.correctAnswerIndex = child.value["correctAnswer"] as! Int
//                            self.generateAnswers()
//                            self.questionIndex = child.value["index"] as! Int
//                            self.questionKey = child.key!
//                                
//                            self.startCountDown()
                        })
                    } else {
                        self.noQuestionAlert()
                    }
                } else {
                    self.noQuestionAlert()
                }
            
            }, withCancelBlock: { error in
                print(error.description)
            })
            
        }) { (error) in
            print(error.description)
        }
    }
    
    func generateAnswers() {
        var buttons = [1, 2, 3, 4]
        let correctButtonIndex = Int(arc4random_uniform(UInt32(buttons.count)))
        print("correct button index: \(correctButtonIndex)")
        var answers = ["Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise"]
        var tag = buttons[correctButtonIndex]
        print("initial tag: \(tag)")
        var button = self.view.viewWithTag(tag) as? UIButton
        
        button?.setTitle(answers[correctAnswerIndex], forState: .Normal)
        
        buttons.removeAtIndex(correctButtonIndex)
        answers.removeAtIndex(correctAnswerIndex)
        
        for (var i = 0; i < 3; i++) {
            print("length of buttons: \(buttons.count) length of answers: \(answers.count)")
            let randomButtonIndex = Int(arc4random_uniform(UInt32(buttons.count)))
            let randomAnswerIndex = Int(arc4random_uniform(UInt32(answers.count)))
            
            tag = buttons[randomButtonIndex]
            print("tag: \(tag)")
            
            button = self.view.viewWithTag(tag) as? UIButton
            
            button?.setTitle(answers[randomAnswerIndex], forState: .Normal)
            
            buttons.removeAtIndex(randomButtonIndex)
            answers.removeAtIndex(randomAnswerIndex)
        }
    }
    
    func nextQuestion() {
        if let child = emulator.nextObject() {
            let to = child.value["to"] as! String
            
            if (to == "" || to == progressId) {
                let base64String = child.value["image"] as! String
                let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let decodedImage = UIImage(data: data!, scale: 0.1)
                self.questionImage.image = decodedImage
                
                self.correctAnswerIndex = child.value["correctAnswer"] as! Int
                
                generateAnswers()
                
                self.questionIndex = child.value["index"] as! Int
                self.questionKey = child.key!
                
                self.startCountDown()
            } else {
                nextQuestion()
            }
        } else {
            loadIncorrectQuestion()
        }
    }
    
    //This evaluate the question value. Decrease the value of wrong answered question and increase the value of correct answer in range (-1,0,1)[wrongly answered, unanswered and correctly answered]
    func questionValue(){
        
    }
    
    //This function make a replica in progress, this should be initial when question first loaded
//    func replica(questionKey:AnyObject, index:AnyObject){
//        let ref = Firebase(url: "https://autimisticapp.firebaseio.com/app/progress")
//        let refRe = ref.childByAppendingPath("\(progressId)/replica/facial")
//        let post = ["index":index,"evaluation":"0","wrongTimes":"0","rightTimes":"0","timeAverage":"0"]
//        if refRe.valueForKeyPath(questionKey as! String) is NSNull {
//            refRe.childByAppendingPath(questionKey as! String).setValue(post)
//        }
//        
//    }
    
    func calculatePoints() {
        if (correctAnswersCounter >= 2) {
            points += unitPoint * correctAnswersCounter
            totalPoints += unitPoint * correctAnswersCounter
        } else {
            points += unitPoint
            totalPoints += unitPoint
        }
        
        pointsLabel.text = "\(points)"
    }
    
    //This is for verifying the the answer of questions
    func checkAnswer(button : UIButton) {
        stopCountDown()
        
        let emotion = answers[correctAnswerIndex].lowercaseString.capitalizedString
        
        let progressRef = self.ref.childByAppendingPath("progress/\(progressId)/facial")
        
        var answeredCorrectly = false
        
        var incorrectQuestionKey = ""
        
        if (button.titleLabel?.text == self.answers[self.correctAnswerIndex]) {
            answeredCorrectly = true
            
            correctAnswersCounter += 1
        } else {
            correctAnswersCounter = 0
        }
        
        var numCorrectEmotionAnswers : Int?
        var numEmotionAnswers : Int?
        var numCorrectAnswers : Int?
        var numIncorrectAnswers : Int?
        var numTotalAnswers : Int?
        
        var totalAnswerTime : Int?
        
        var longestStreak : Int?
        
        var incorrectQuestions : String?
        
        var currentQuestionIndex : Int?
        
        progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            let properties = snapshot.value
            
            print("data: \(properties)")
            numCorrectEmotionAnswers = properties["numCorrect\(emotion)Answers"] as? Int
            numEmotionAnswers        = properties["num\(emotion)Answers"] as? Int
            numCorrectAnswers        = properties["numCorrectAnswers"] as? Int
            numIncorrectAnswers      = properties["numIncorrectAnswers"] as? Int
            numTotalAnswers          = properties["numTotalAnswers"] as? Int
            
            totalAnswerTime          = properties["totalAnswerTime"] as? Int
            
            longestStreak            = properties["longestStreak"] as? Int
            
            incorrectQuestions       = properties["incorrectQuestions"] as? String
            
            currentQuestionIndex     = self.questionIndex
            
            var updates = [String:AnyObject]()
            
            if (answeredCorrectly) {
                if (numCorrectEmotionAnswers == nil) {
                    updates["numCorrect\(emotion)Answers"] = 1
                } else {
                    numCorrectEmotionAnswers! += 1
                
                    updates["numCorrect\(emotion)Answers"] = numCorrectEmotionAnswers
                }
                
                if (numCorrectAnswers == nil) {
                    updates["numCorrectAnswers"] = 1
                } else {
                    numCorrectAnswers! += 1
                    
                    updates["numCorrectAnswers"] = numCorrectAnswers
                }
                
                if (longestStreak == nil) {
                    updates["longestStreak"] = self.correctAnswersCounter
                } else {
                    if (longestStreak < self.correctAnswersCounter) {
                        updates["longestStreak"] = self.correctAnswersCounter
                    }
                }
            } else {
                incorrectQuestionKey = "\(self.questionKey)"
                
                if (numIncorrectAnswers == nil) {
                    updates["numIncorrectAnswers"] = 1
                } else {
                    numIncorrectAnswers! += 1
                    
                    updates["numIncorrectAnswers"] = numIncorrectAnswers
                }
                
                if (incorrectQuestions == nil || incorrectQuestions == "") {
                    updates["incorrectQuestions"] = "\(incorrectQuestionKey)"
                } else {
                    updates["incorrectQuestions"] = incorrectQuestions! + " \(incorrectQuestionKey)";
                }
            }
            
            if (numTotalAnswers == nil) {
                updates["numTotalAnswers"] = 1
            } else {
                numTotalAnswers! += 1
                
                updates["numTotalAnswers"] = numTotalAnswers
            }
            
            if (numEmotionAnswers == nil) {
                updates["num\(emotion)Answers"] = 1
            } else {
                numEmotionAnswers! += 1
                
                updates["num\(emotion)Answers"] = numEmotionAnswers
            }
            
            if (totalAnswerTime == nil) {
                updates["totalAnswerTime"] = 20 - self.counter
            } else {
                totalAnswerTime! += (20 - self.counter)
                
                updates["totalAnswerTime"] = totalAnswerTime
            }
            
            if (!self.reloadIncorrectQuestions) {
                updates["currentQuestionIndex"] = currentQuestionIndex
            }
            
            if (answeredCorrectly) {
                self.calculatePoints()
                updates["totalPoints"] = self.totalPoints
            }
            
            progressRef.updateChildValues(updates, withCompletionBlock: { (error, ref) in
                if (answeredCorrectly) {
                    self.correctAlert()
                } else {
                    self.incorrectAlert()
                }
            })
            
            }, withCancelBlock: { (error) in
                print(error.description)
        })
        
    }
    
    func correctAlert() {
        nextQuestion()
        
        self.gameStatusLabel.textColor = UIColor(red: 10/255, green: 224/255, blue: 103/255, alpha: 1.0)
        
        if (correctAnswersCounter >= 2) {
            self.gameStatusLabel.text = "☆ \(correctAnswersCounter)X Points ☆"
            self.gameStatusLabel.hidden = false
            
            self.encouragementLabel.hidden = false
        } else if (correctAnswersCounter == 1) {
            self.gameStatusLabel.text = "That was correct!"
            self.gameStatusLabel.hidden = false
        }
    }
    
    func incorrectAlert() {
        nextQuestion()

        self.encouragementLabel.hidden = true
        
        self.gameStatusLabel.text = "That was not correct..."
        self.gameStatusLabel.textColor = UIColor.redColor()
        self.gameStatusLabel.hidden = false
    }
    
    func timesUpAlert() {
//        let alert = UIAlertController(title: "Time's Up!", message: "You are doing great! Just a little bit quicker next time.", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {
//            action in
//            self.nextQuestion()
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
        
        SweetAlert().showAlert("Time's Up", subTitle: "You are doing great! Just need to be a little bit quicker next time.", style: .Warning, buttonTitle: "Okay") { (isOtherButton) in
            self.nextQuestion()
        }
    }
    
    func noQuestionAlert() {
//        let alert = UIAlertController(title: "Good Job!", message: "Wow, you have answered all the questions correctly! Wait for new update packages from us!", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
//            action in
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
        
        stopCountDown()
        
        SweetAlert().showAlert("Awesome!", subTitle: "Wow, you have answered all the questions correctly! Wait for new update packages from us!", style: .Success, buttonTitle: "Back to Games Menu") { (isOtherButton) in
            let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
            self.presentViewController(patientViewController, animated: true, completion: nil)
        }
    }
    
    func startCountDown() {
        stopCountDown()
        
        counter = 20
        
        timerLabel.text = String(counter)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FacialGameViewController.updateCounter), userInfo: nil, repeats: true)
        
        timerBar.progress = Float(0)
    }
    
    func stopCountDown() {
        timer.invalidate()
    }

    //This function serves for countDown
    func updateCounter() {
        counter -= 1
        
        timerLabel.text = String(counter)
        
        timerBar.progress = Float(20 - counter) / Float(20)
        
        if counter == 0 {
            stopCountDown()
            
            let emotion = answers[correctAnswerIndex].lowercaseString.capitalizedString
            
            let incorrectQuestionKey = self.questionKey
            
//            timesUpAlert()
            
            let progressRef = self.ref.childByAppendingPath("progress/\(progressId)/facial")
        
            var numNoAnswers : Int?
            var numEmotionAnswers : Int?
            var numTotalAnswers : Int?
            
            var totalAnswerTime : Int?
            
            var incorrectQuestions : String?
            
            var currentQuestionIndex : Int?
            
            progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let properties = snapshot.value
                
                print("data: \(properties)")
                numNoAnswers         = properties["numNoAnswers"] as? Int
                numEmotionAnswers    = properties["num\(emotion)Answers"] as? Int
                numTotalAnswers      = properties["numTotalAnswers"] as? Int
                
                totalAnswerTime      = properties["totalAnswerTime"] as? Int
                
                incorrectQuestions   = properties["incorrectQuestions"] as? String
                
                currentQuestionIndex = self.questionIndex
                
                var updates = [String:AnyObject]()
                
                if (numNoAnswers == nil) {
                    updates["numNoAnswers"] = 1
                } else {
                    numNoAnswers! += 1
                    
                    updates["numNoAnswers"] = numNoAnswers
                }
                
                if (numTotalAnswers == nil) {
                    updates["numTotalAnswers"] = 1
                } else {
                    numTotalAnswers! += 1
                    
                    updates["numTotalAnswers"] = numTotalAnswers
                }
                
                if (numEmotionAnswers == nil) {
                    updates["num\(emotion)Answers"] = 1
                } else {
                    numEmotionAnswers! += 1
                    
                    updates["num\(emotion)Answers"] = numEmotionAnswers
                }
                
                if (totalAnswerTime == nil) {
                    updates["totalAnswerTime"] = 20
                } else {
                    totalAnswerTime! += 20
                    
                    updates["totalAnswerTime"] = totalAnswerTime
                }
                
                if (incorrectQuestions == nil || incorrectQuestions == "") {
                    updates["incorrectQuestions"] = "\(incorrectQuestionKey)"
                } else {
                    updates["incorrectQuestions"] = incorrectQuestions! + " \(incorrectQuestionKey)";
                }
                
                updates["currentQuestionIndex"] = currentQuestionIndex
                
//                progressRef.updateChildValues(updates)
                
                progressRef.updateChildValues(updates, withCompletionBlock: { (error, ref) in
                    self.timesUpAlert()
                })
                
                }, withCancelBlock: { (error) in
                    print(error.description)
            })
        }
    }
    
    //This function serves for random generation
    func random(number:UInt32) -> Int {
        let randomNumber = Int(arc4random_uniform(number))
        return randomNumber
    }
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        stopCountDown()
        
        if (segue.identifier == "StopFacialGameSegue") {
            if let destination = segue.destinationViewController as? StopFacialGameViewController {
                if (points == 0) {
                    let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                    self.presentViewController(patientViewController, animated: true, completion: nil)
                } else {
                    destination.earnedPoints = points
                    destination.totalPoints = totalPoints
                }
            }
        }
    }
    
}
