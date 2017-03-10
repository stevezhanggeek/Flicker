import UIKit
import Eureka

class StudyVC: FormViewController {
    var resultView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("")
            <<< IntRow("ParticipantID"){ row in
                row.title = "Participant ID"
                row.placeholder = ""
                }.onChange { row in
                    if row.value != nil {
                        self.updateResultView()
                    }
            }
            <<< IntRow("Age"){ row in
                row.title = "Age"
                row.placeholder = ""
            }
            <<< TextRow("Gender") { row in
                row.title = "Gender"
                row.placeholder = ""
            }
        
        let startButton = UIButton(frame: CGRectMake(0, screenH - 80, screenW, 80))
        startButton.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 1)
        startButton.addTarget(self, action: #selector(self.startButtonTouched), forControlEvents: .TouchUpInside)
        startButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startButton.setTitle("Start", forState: .Normal)
        self.view.addSubview(startButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateResultView()
    }
    
    func updateResultView() {
        resultView.removeFromSuperview()
        resultView = UIView(frame: CGRectMake(0, 270, screenW, 300))
        self.view.addSubview(resultView)
        
        let row: IntRow? = form.rowByTag("ParticipantID")
        
        if let participantID = row!.value {
            let order = latinSquare[participantID % 6]
            
            for i in 0 ..< 6 {
                let row = UIView(frame: CGRectMake(0, CGFloat(i) * 50, screenW, 50))
                let orderLabel = UILabel(frame: CGRectMake(0, 0, 50, 50))
                orderLabel.text = String(order[i])
                orderLabel.textAlignment = .Center
                row.addSubview(orderLabel)
                if studyProgress >= i {
                    let resultLabel = UILabel(frame: CGRectMake(50, 0, screenW - 130, 50))
                    var text = ""
                    let resultList = finalResult.testResultList[i]
                    for result in resultList {
                        text += String(result.1) + ", "
                    }
                    resultLabel.text = text
                    row.addSubview(resultLabel)
                    
                    let redoButton = UIButton(frame: CGRectMake(screenW - 80, 0, 80, 50))
                    redoButton.setTitle("Redo", forState: .Normal)
                    redoButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                    redoButton.tag = i
                    redoButton.addTarget(self, action: #selector(self.redoButtonTouched(_:)), forControlEvents: .TouchUpInside)
                    row.addSubview(redoButton)
                }
                
                resultView.addSubview(row)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTestVCFromStudyVC" {
            let vc = segue.destinationViewController as! TestVC
            
            let row: IntRow? = form.rowByTag("ParticipantID")
            if let participantID = row!.value {
                let order = latinSquare[participantID % 6]
                if sender == nil {
                    // Next study
                    vc.index = studyProgress
                    vc.studyCondition = allStudyConditionList[order[studyProgress]]
                } else {
                    // Redo
                    vc.index = sender as! Int
                    vc.studyCondition = allStudyConditionList[order[sender as! Int]]
                }
            }
        }
    }
    
    func redoButtonTouched(sender: UIButton) {
        let tag = sender.tag
        self.performSegueWithIdentifier("showTestVCFromStudyVC", sender: tag)
    }
    
    func startButtonTouched() {
        if finalResult.participantInfo == nil {
            finalResult.participantInfo = form.values()
            print("Participant Info recorded")
        }
        
        if (studyProgress >= 5) {
            let alertController = UIAlertController(title: "All 6 Tests Completed!", message: "", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            studyProgress += 1
            self.performSegueWithIdentifier("showTestVCFromStudyVC", sender: nil)
        }
    }
}

