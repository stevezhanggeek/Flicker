import UIKit
import Eureka

class StudyVC: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("")
            <<< IntRow("ParticipantID"){ row in
                row.title = "Participant ID"
                row.placeholder = ""
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTestVCFromStudyVC" {
            let vc = segue.destinationViewController as! TestVC
            vc.studyCondition = allStudyConditionList[studyProgress]
        }
    }

    
    func startButtonTouched() {
        if finalResult.participantInfo == nil {
            finalResult.participantInfo = form.values()
            print("Participant Info recorded")
        }
        
        if (studyProgress >= 6) {
            let alertController = UIAlertController(title: "All 6 Tests Completed!", message: "", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier("showTestVCFromStudyVC", sender: self)
        }
    }
}

