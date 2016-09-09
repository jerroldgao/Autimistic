//
//  ComplexLanguageGameProgressViewController.swift
//  Autimistic
//
//  Created by Quan K. Huynh on 4/23/16.
//  Copyright © 2016 CS309_G27_iastate. All rights reserved.
//

import UIKit
import Firebase
import Charts

class ComplexLanguageGameProgressViewController: UIViewController {
    
    let ref = Firebase(url:"https://autimisticapp.firebaseio.com")
    
    var progressId : String!

    @IBAction func savePieChartImageButtonTapped(sender: AnyObject) {
        pieChartView.saveToCameraRoll()
        
        SweetAlert().showAlert("Success!", subTitle: "The chart has been saved to Photos", style: AlertStyle.Success)
    }
    
    @IBAction func saveRadarChartImageButtonTapped(sender: AnyObject) {
        radarChartView.saveToCameraRoll()
        
        SweetAlert().showAlert("Success!", subTitle: "The chart has been saved to Photos", style: AlertStyle.Success)
    }
    
    @IBOutlet weak var resetDataButton: UIButton!
    
    @IBAction func resetDataButtonTapped(sender: AnyObject) {
        SweetAlert().showAlert("Reset Data", subTitle: "Are you sure? This action cannot be undone.", style: .Warning, buttonTitle: "No", buttonColor: UIColor.grayColor(), otherButtonTitle: "Yes", otherButtonColor: UIColor.redColor()) { (isOtherButton) in
            let resetData = ["currentQuestionIndex": 0, "incorrectQuestions": "", "longestStreak": 0, "numSarcasmAnswers": 0, "numCorrectSarcasmAnswers": 0, "numHyperboleAnswers": 0, "numCorrectHyperboleAnswers": 0, "numPunAnswers": 0, "numCorrectPunAnswers": 0, "numCorrectAnswers": 0, "numIncorrectAnswers": 0, "numNoAnswers": 0, "numTotalAnswers": 0, "totalAnswerTime": 0, "totalPoints": 0]
            
            self.ref.childByAppendingPath("progress/\(self.progressId)/complex").setValue(resetData, withCompletionBlock: { (error, firebase) in
                if (error == nil) {
                    SweetAlert().showAlert("Success!", subTitle: "Complex language game data has been reset", style: .Success, buttonTitle: "Back to Games Menu", buttonColor: UIColor.greenColor(), action: { (isOtherButton) in
                        let patientViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PatientNavigation")
                        self.presentViewController(patientViewController, animated: true, completion: nil)
                    })
                } else {
                    SweetAlert().showAlert("Oops...", subTitle: "There was a problem. Please try again later.", style: AlertStyle.Error)
                }
            })
        }
    }
    
    @IBOutlet weak var addDoctorButton: UIBarButtonItem!

    @IBAction func addDoctorButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("ComplexLanguageProgressToAddDoctor", sender: self)
    }
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var radarChartView: RadarChartView!
    
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    @IBOutlet weak var totalAnswersLabel: UILabel!
    
    @IBOutlet weak var longestStreakLabel: UILabel!
    
    @IBOutlet weak var averageAnswerTimeLabel: UILabel!
    
    @IBOutlet weak var totalCorrectAnswersLabel: UILabel!
    
    @IBOutlet weak var totalIncorrectAnswersLabel: UILabel!
    
    @IBOutlet weak var totalMissedAnswersLabel: UILabel!
    
    @IBOutlet weak var correctHyperboleAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctPunAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctSarcasmAnswersPercentageLabel: UILabel!
    
    @IBOutlet weak var correctHyperboleAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctPunAnswersProgressView: UIProgressView!
    
    @IBOutlet weak var correctSarcasmAnswersProgressView: UIProgressView!
    
    var longestStreak : Int!
    
    var totalAnswerTime : Int!
    
    var totalPoints : Int!
    
    var totalAnswers : Int!
    
    var numCorrectAnswers : Int!
    
    var numIncorrectAnswers : Int!
    
    var numMissedAnswers : Int!
    
    var numCorrectHyperboleAnswers : Int!
    
    var numHyperboleAnswers : Int!
    
    var numCorrectPunAnswers : Int!
    
    var numPunAnswers : Int!
    
    var numCorrectSarcasmAnswers : Int!
    
    var numSarcasmAnswers : Int!
    
    
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
                    
                    let progressRef = self.ref.childByAppendingPath("progress/\(self.progressId)/complex")
                    
                    progressRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        let data = snapshot.value
                        
                        self.longestStreak = data["longestStreak"] as? Int
                        self.totalAnswerTime = data["totalAnswerTime"] as? Int
                        self.totalPoints = data["totalPoints"] as? Int
                        
                        self.totalAnswers = data["numTotalAnswers"] as? Int
                        self.numCorrectAnswers = data["numCorrectAnswers"] as? Int
                        self.numIncorrectAnswers = data["numIncorrectAnswers"] as? Int
                        self.numMissedAnswers = data["numNoAnswers"] as? Int
                        
                        self.numHyperboleAnswers = data["numHyperboleAnswers"] as? Int
                        self.numCorrectHyperboleAnswers = data["numCorrectHyperboleAnswers"] as? Int
                        let correctHyperboleAnswersPercentage = self.correctAnswersPercentage(self.numCorrectHyperboleAnswers, numAnswers: self.numHyperboleAnswers)
                        
                        self.numPunAnswers = data["numPunAnswers"] as? Int
                        self.numCorrectPunAnswers = data["numCorrectPunAnswers"] as? Int
                        let correctPunAnswersPercentage = self.correctAnswersPercentage(self.numCorrectPunAnswers, numAnswers: self.numPunAnswers)
                        
                        self.numSarcasmAnswers = data["numSarcasmAnswers"] as? Int
                        self.numCorrectSarcasmAnswers = data["numCorrectSarcasmAnswers"] as? Int
                        let correctSarcasmAnswersPercentage = self.correctAnswersPercentage(self.numCorrectSarcasmAnswers, numAnswers: self.numSarcasmAnswers)
                        
                        self.totalPointsLabel.text = (self.isNil(self.totalPoints)) ? "No data" : "\(self.totalPoints)"
                        
                        self.totalAnswersLabel.text = (self.isNil(self.totalAnswers)) ? "No data" : "\(self.totalAnswers)"
                        
                        self.longestStreakLabel.text = (self.isNil(self.longestStreak)) ? "No data" : "\(self.longestStreak)"
                        
                        self.averageAnswerTimeLabel.text = (self.isNil(self.totalAnswerTime) || self.isNil(self.totalAnswers) || self.totalAnswers == 0) ? "No data" : "\(self.totalAnswerTime / self.totalAnswers) second(s)"
                        
                        self.totalCorrectAnswersLabel.text = (self.isNil(self.numCorrectAnswers)) ? "No data" : "\(self.numCorrectAnswers)"
                        
                        self.totalIncorrectAnswersLabel.text = (self.isNil(self.numIncorrectAnswers)) ? "No data" : "\(self.numIncorrectAnswers)"
                        
                        self.totalMissedAnswersLabel.text = (self.isNil(self.numMissedAnswers)) ? "No data" : "\(self.numMissedAnswers)"
                        
                        self.setPieChart()
                        
                        self.correctHyperboleAnswersPercentageLabel.text = (correctHyperboleAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctHyperboleAnswersPercentage  * 100) + "%"
                        
                        self.correctHyperboleAnswersProgressView.progress = (correctHyperboleAnswersPercentage == -1.0) ? 0.0 : Float(correctHyperboleAnswersPercentage)
                        
                        self.correctPunAnswersPercentageLabel.text = (correctPunAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctPunAnswersPercentage  * 100) + "%"
                        
                        self.correctPunAnswersProgressView.progress = (correctPunAnswersPercentage == -1.0) ? 0.0 : Float(correctPunAnswersPercentage)
                        
                        self.correctSarcasmAnswersPercentageLabel.text = (correctSarcasmAnswersPercentage == -1.0) ? "No data" : String(format: "%.2f%", correctSarcasmAnswersPercentage  * 100) + "%"
                        
                        self.correctSarcasmAnswersProgressView.progress = (correctSarcasmAnswersPercentage == -1.0) ? 0.0 : Float(correctSarcasmAnswersPercentage)
                        
                        self.setRadarChart([correctHyperboleAnswersPercentage, correctPunAnswersPercentage, correctSarcasmAnswersPercentage])
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

    func correctAnswersPercentage(numCorrectAnswers : Int?, numAnswers : Int?) -> Double {
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
    
    func setPieChart() {
        if (numCorrectAnswers != nil && numIncorrectAnswers != nil && numMissedAnswers != nil && totalAnswers != nil) {
            let correctPercentage = Double(numCorrectAnswers) / Double(totalAnswers)
            let incorrectPercentage = Double(numIncorrectAnswers) / Double(totalAnswers)
            let missedPercentage = Double(numMissedAnswers) / Double(totalAnswers)
            
            let dataPoints = ["Correct", "Incorrect", "Missed"]
            let values = [correctPercentage, incorrectPercentage, missedPercentage]
            
            pieChartView.noDataText = "No data available."
            pieChartView.descriptionText = ""
            pieChartView.holeColor = UIColor.darkGrayColor()
            pieChartView.legend.colors = [UIColor.whiteColor(), UIColor.whiteColor(), UIColor.whiteColor()]
            
            var dataEntries : [ChartDataEntry] = []
            
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
                
                dataEntries.append(dataEntry)
            }
            
            let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Answers")
            let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
            
            pieChartView.data = pieChartData
            
            pieChartDataSet.colors = ChartColorTemplates.colorful()
            
            let formatter = NSNumberFormatter()
            
            formatter.numberStyle = .PercentStyle
            
            pieChartDataSet.valueFormatter = formatter
            
            pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
            pieChartView.notifyDataSetChanged()
        }
    }
    
    func setRadarChart(values : [Double]) {
        let dataPoints = ["Hyperbole", "Pun", "Sarcasm"]
        
        radarChartView.noDataText = "No data available."
        radarChartView.descriptionText = ""
        radarChartView.xAxis.labelTextColor = UIColor.whiteColor()
        radarChartView.yAxis.labelTextColor = UIColor.whiteColor()
        radarChartView.legend.enabled = false
        radarChartView.webAlpha = 1.0
        radarChartView.webLineWidth = 2.0
        
        var dataEntries : [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: (values[i] == 1.0) ? 1.0 : values[i], xIndex: i)
            
            dataEntries.append(dataEntry)
        }
        
        let radarChartDataSet = RadarChartDataSet(yVals: dataEntries, label: "")
        let radarChartData = RadarChartData(xVals: dataPoints, dataSet: radarChartDataSet)
        
        radarChartView.data = radarChartData
        
        radarChartDataSet.colors = ChartColorTemplates.vordiplom()
        
        radarChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        radarChartView.notifyDataSetChanged()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ComplexLanguageProgressToAddDoctor") {
            let destinationVC = segue.destinationViewController as! ParentAddDoctorViewController
            
            destinationVC.selectedProgressID = selectedProgressID
        }
    }

}
