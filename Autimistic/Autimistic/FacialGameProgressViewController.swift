//
//  FacialGameProgressViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 3/31/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import Charts

class FacialGameProgressViewController: UIViewController {
    
    let ref = Firebase(url:"https://autimisticapp.firebaseio.com")
    
    var progressId : String!

    @IBAction func saveCorrectnessPieChartImageButtonTapped(sender: AnyObject) {
        correctnessPieChartView.saveToCameraRoll()
        
        SweetAlert().showAlert("Success!", subTitle: "The chart has been saved to Photos", style: AlertStyle.Success)
    }
    
    @IBAction func saveEmotionsRadarChartImageButtonTapped(sender: AnyObject) {
        emotionsRadarChart.saveToCameraRoll()
        
        SweetAlert().showAlert("Success!", subTitle: "The chart has been saved to Photos", style: AlertStyle.Success)
    }
    
    @IBOutlet weak var resetDataButton: UIButton!
    
    @IBAction func resetDataButtonTapped(sender: AnyObject) {
        SweetAlert().showAlert("Reset Data", subTitle: "Are you sure? This action cannot be undone.", style: .Warning, buttonTitle: "No", buttonColor: UIColor.grayColor(), otherButtonTitle: "Yes", otherButtonColor: UIColor.redColor()) { (isOtherButton) in
            let resetData = ["currentQuestionIndex": 0, "incorrectQuestions": "", "longestStreak": 0, "numAngerAnswers": 0, "numCorrectAngerAnswers": 0, "numDisgustAnswers": 0, "numCorrectDisgustAnswers": 0, "numFearAnswers": 0, "numCorrectFearAnswers": 0, "numHappinessAnswers": 0, "numCorrectHappinessAnswers": 0, "numSadnessAnswers": 0, "numCorrectSadnessAnswers": 0, "numSurpriseAnswers": 0, "numCorrectSurpriseAnswers": 0, "numCorrectAnswers": 0, "numIncorrectAnswers": 0, "numNoAnswers": 0]
            
            self.ref.childByAppendingPath("progress/\(self.progressId)/facial").setValue(resetData, withCompletionBlock: { (error, firebase) in
                if (error == nil) {
                    SweetAlert().showAlert("Success!", subTitle: "Facial recognition game data has been reset", style: .Success, buttonTitle: "Back to Games Menu", buttonColor: UIColor.greenColor(), action: { (isOtherButton) in
                        let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                        self.presentViewController(patientViewController, animated: true, completion: nil)
                    })
                } else {
                    SweetAlert().showAlert("Oops...", subTitle: "There was a problem. Please try again later.", style: AlertStyle.Error)
                }
            })
        }
    }
    
//    @IBOutlet weak var addDoctorButton: UIBarButtonItem!
//    @IBAction func addDoctorButtonTapped(sender: AnyObject) {
//        performSegueWithIdentifier("ProgressToAddDoctor", sender: self)
//    }

    
    @IBOutlet weak var correctnessPieChartView: PieChartView!
    
    @IBOutlet weak var emotionsRadarChart: RadarChartView!
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    @IBOutlet weak var totalAnswersLabel: UILabel!
    
    @IBOutlet weak var longestStreakLabel: UILabel!
    
    @IBOutlet weak var averageAnswerTimeLabel: UILabel!
    
    @IBOutlet weak var totalCorrectAnswersLabel: UILabel!
    
    @IBOutlet weak var totalIncorrectAnswersLabel: UILabel!
    
    @IBOutlet weak var totalMissedAnswersLabel: UILabel!
    
    @IBOutlet weak var correctAngerAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctDisgustAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctFearAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctHappinessAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctSadnessAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctSurpriseAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctAngerAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctDisgustAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctFearAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctHappinessAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctSadnessAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctSurpriseAnswersProgressView: UIProgressView!
    
    var longestStreak : Int!
    
    var totalAnswerTime : Int!
    
    var totalPoints : Int!
    
    var totalAnswers : Int!
    
    var numCorrectAnswers : Int!
    
    var numIncorrectAnswers : Int!
    
    var numMissedAnswers : Int!
    
    var numCorrectAngerAnswers : Int!
    
    var numAngerAnswers : Int!
    
    var numCorrectDisgustAnswers : Int!
    
    var numDisgustAnswers : Int!
    
    var numCorrectFearAnswers : Int!
    
    var numFearAnswers : Int!
    
    var numCorrectHappinessAnswers : Int!
    
    var numHappinessAnswers : Int!
    
    var numCorrectSadnessAnswers : Int!
    
    var numSadnessAnswers : Int!
    
    var numCorrectSurpriseAnswers : Int!
    
    var numSurpriseAnswers : Int!
    
    
    var isParent = false
    
    var isPatient = false
    
    var selectedProgressID : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref.observeAuthEventWithBlock { (authData) in
            if (authData != nil) {
                let userRef = self.ref.childByAppendingPath("users/\(authData.uid)")
                
                userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if (snapshot.value["role"] as! String == "Parent") {
                        self.isParent = true
                    } else {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    
                    if (snapshot.value["role"] as! String == "Patient") {
                        self.isPatient = true
                    } else {
                        self.resetDataButton.hidden = true
                    }
                    
                    if (self.selectedProgressID != nil && !self.selectedProgressID.isEmpty) {
                        print("HELLO \(self.selectedProgressID)")
                        self.progressId = self.selectedProgressID
                    } else {
                        let index = authData.uid.characters.count - 8
                        
                        self.progressId = (authData.uid as NSString).substringFromIndex(index) as String
                    }
                    
                    print(self.progressId)
                    
                    let progressRef = self.ref.childByAppendingPath("progress/\(self.progressId)/facial")
                    
                    progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        let data = snapshot.value
                        
                        self.longestStreak = data["longestStreak"] as? Int
                        self.totalAnswerTime = data["totalAnswerTime"] as? Int
                        self.totalPoints = data["totalPoints"] as? Int
                        
                        self.totalAnswers = data["numTotalAnswers"] as? Int
                        self.numCorrectAnswers = data["numCorrectAnswers"] as? Int
                        self.numIncorrectAnswers = data["numIncorrectAnswers"] as? Int
                        self.numMissedAnswers = data["numNoAnswers"] as? Int
                        
                        self.numAngerAnswers = data["numAngerAnswers"] as? Int
                        self.numCorrectAngerAnswers = data["numCorrectAngerAnswers"] as? Int
                        let correctAngerAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectAngerAnswers, numEmotionAnswers: self.numAngerAnswers)
                        
                        self.numDisgustAnswers = data["numDisgustAnswers"] as? Int
                        self.numCorrectDisgustAnswers = data["numCorrectDisgustAnswers"] as? Int
                        let correctDisgustAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectDisgustAnswers, numEmotionAnswers: self.numDisgustAnswers)
                        
                        self.numFearAnswers = data["numFearAnswers"] as? Int
                        self.numCorrectFearAnswers = data["numCorrectFearAnswers"] as? Int
                        let correctFearAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectFearAnswers, numEmotionAnswers: self.numFearAnswers)
                        
                        self.numHappinessAnswers = data["numHappinessAnswers"] as? Int
                        self.numCorrectHappinessAnswers = data["numCorrectHappinessAnswers"] as? Int
                        let correctHappinessAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectHappinessAnswers, numEmotionAnswers: self.numHappinessAnswers)
                        
                        self.numSadnessAnswers = data["numSadnessAnswers"] as? Int
                        self.numCorrectSadnessAnswers = data["numCorrectSadnessAnswers"] as? Int
                        let correctSadnessAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectSadnessAnswers, numEmotionAnswers: self.numSadnessAnswers)
                        
                        self.numSurpriseAnswers = data["numSurpriseAnswers"] as? Int
                        self.numCorrectSurpriseAnswers = data["numCorrectSurpriseAnswers"] as? Int
                        let correctSurpriseAnswersPercentage = self.correctEmotionAnswersPercentage(self.numCorrectSurpriseAnswers, numEmotionAnswers: self.numSurpriseAnswers)
                        
                        self.totalPointsLabel.text = (self.isNil(self.totalPoints)) ? "No data" : "\(self.totalPoints)"
                        
                        self.totalAnswersLabel.text = (self.isNil(self.totalAnswers)) ? "No data" : "\(self.totalAnswers)"
                        
                        self.longestStreakLabel.text = (self.isNil(self.longestStreak)) ? "No data" : "\(self.longestStreak)"
                        
                        self.averageAnswerTimeLabel.text = (self.isNil(self.totalAnswerTime) || self.isNil(self.totalAnswers)) ? "No data" : "\(self.totalAnswerTime / self.totalAnswers) second(s)"
                        
                        self.totalCorrectAnswersLabel.text = (self.isNil(self.numCorrectAnswers)) ? "No data" : "\(self.numCorrectAnswers)"
                        
                        self.totalIncorrectAnswersLabel.text = (self.isNil(self.numIncorrectAnswers)) ? "No data" : "\(self.numIncorrectAnswers)"
                        
                        self.totalMissedAnswersLabel.text = (self.isNil(self.numMissedAnswers)) ? "No data" : "\(self.numMissedAnswers)"
                        
                        self.setCorrectnessPieChart()
                        
                        self.correctAngerAnswersPercentageLabel.text = (correctAngerAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctAngerAnswersPercentage  * 100) + "%"
                        
                        self.correctAngerAnswersProgressView.progress = (correctAngerAnswersPercentage == -1.0) ? 0.0 : Float(correctAngerAnswersPercentage)
                        
                        self.correctDisgustAnswersPercentageLabel.text = (correctDisgustAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctDisgustAnswersPercentage  * 100) + "%"
                        
                        self.correctDisgustAnswersProgressView.progress = (correctDisgustAnswersPercentage == -1.0) ? 0.0 : Float(correctDisgustAnswersPercentage)
                        
                        self.correctFearAnswersPercentageLabel.text = (correctFearAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctFearAnswersPercentage  * 100) + "%"
                        
                        self.correctFearAnswersProgressView.progress = (correctFearAnswersPercentage == -1.0) ? 0.0 : Float(correctFearAnswersPercentage)
                        
                        self.correctHappinessAnswersPercentageLabel.text = (correctHappinessAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctHappinessAnswersPercentage  * 100) + "%"
                        
                        self.correctHappinessAnswersProgressView.progress = (correctHappinessAnswersPercentage == -1.0) ? 0.0 : Float(correctHappinessAnswersPercentage)
                        
                        self.correctSadnessAnswersPercentageLabel.text = (correctSadnessAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctSadnessAnswersPercentage  * 100) + "%"
                        
                        self.correctSadnessAnswersProgressView.progress = (correctSadnessAnswersPercentage == -1.0) ? 0.0 : Float(correctSadnessAnswersPercentage)
                        
                        self.correctSurpriseAnswersPercentageLabel.text = (correctSurpriseAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctSurpriseAnswersPercentage  * 100) + "%"
                        
                        self.correctSurpriseAnswersProgressView.progress = (correctSurpriseAnswersPercentage == -1.0) ? 0.0 : Float(correctSurpriseAnswersPercentage)
                        
                        self.setRadarChart([correctAngerAnswersPercentage, correctDisgustAnswersPercentage, correctFearAnswersPercentage, correctHappinessAnswersPercentage, correctSadnessAnswersPercentage, correctSurpriseAnswersPercentage])
                    }) { (error) in
                        print(error.description)
                    }
                })
            } else {
                SweetAlert().showAlert("Oops...", subTitle: "Something is wrong. We are looking into it. Please try again later.", style: .Error, buttonTitle: "Back to Games Menu") { (isOtherButton) in
                    let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                    self.presentViewController(patientViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func correctEmotionAnswersPercentage(numCorrectEmotionAnswers : Int?, numEmotionAnswers : Int?) -> Double {
        let numCorrectAnswers = numCorrectEmotionAnswers
        let numAnswers = numEmotionAnswers
        
        if (numCorrectAnswers == nil || numAnswers == nil) {
            return -1.0
        } else {
            return (Double(numCorrectAnswers!) / Double(numAnswers!))
        }
    }
    
    func isNil(value : AnyObject?) -> Bool {
        let mirror = Mirror(reflecting: value)
        
        if (mirror.subjectType == String.self && value as! String == "") {
            return true
        }
        
        return (value == nil) ? true : false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCorrectnessPieChart() {
        if (numCorrectAnswers != nil && numIncorrectAnswers != nil && numMissedAnswers != nil && totalAnswers != nil) {
            let correctPercentage = Double(numCorrectAnswers) / Double(totalAnswers)
            let incorrectPercentage = Double(numIncorrectAnswers) / Double(totalAnswers)
            let missedPercentage = Double(numMissedAnswers) / Double(totalAnswers)
            
            let dataPoints = ["Correct", "Incorrect", "Missed"]
            let values = [correctPercentage, incorrectPercentage, missedPercentage]
            
            correctnessPieChartView.noDataText = "No data available."
            correctnessPieChartView.descriptionText = ""
            correctnessPieChartView.holeColor = UIColor.darkGrayColor()
            correctnessPieChartView.legend.colors = [UIColor.whiteColor(), UIColor.whiteColor(), UIColor.whiteColor()]
            
            var dataEntries : [ChartDataEntry] = []
            
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
                
                dataEntries.append(dataEntry)
            }
            
            let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Answers")
            let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
            
            correctnessPieChartView.data = pieChartData
            
            pieChartDataSet.colors = ChartColorTemplates.colorful()
            
            let formatter = NSNumberFormatter()
            
            formatter.numberStyle = .PercentStyle
            
            pieChartDataSet.valueFormatter = formatter
            
            correctnessPieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
            correctnessPieChartView.notifyDataSetChanged()
        }
    }
    
    func setRadarChart(values : [Double]) {
        let dataPoints = ["Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise"]
            
        emotionsRadarChart.noDataText = "No data available."
        emotionsRadarChart.descriptionText = ""
        emotionsRadarChart.xAxis.labelTextColor = UIColor.whiteColor()
        emotionsRadarChart.yAxis.labelTextColor = UIColor.whiteColor()
        emotionsRadarChart.legend.enabled = false
        emotionsRadarChart.webAlpha = 1.0
        emotionsRadarChart.webLineWidth = 2.0
        
        var dataEntries : [ChartDataEntry] = []
            
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: (values[i] == 1.0) ? 0.0 : values[i], xIndex: i)
                
            dataEntries.append(dataEntry)
        }
            
        let radarChartDataSet = RadarChartDataSet(yVals: dataEntries, label: "")
        let radarChartData = RadarChartData(xVals: dataPoints, dataSet: radarChartDataSet)
            
        emotionsRadarChart.data = radarChartData
        
        radarChartDataSet.colors = ChartColorTemplates.vordiplom()
        
        emotionsRadarChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        emotionsRadarChart.notifyDataSetChanged()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if (segue.identifier == "FacialProgressToAddDoctor") {
//            let destinationVC = segue.destinationViewController as! ParentAddDoctorViewController
//            
//            destinationVC.selectedProgressID = selectedProgressID
//        }
//    }


}
