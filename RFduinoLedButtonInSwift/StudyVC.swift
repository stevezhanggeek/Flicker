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
        
        let startButton = UIButton(frame: CGRect(x:0, y:screenH - 80, width:screenW, height:80))
        startButton.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 1)
        startButton.addTarget(self, action: #selector(self.startButtonTouched), for: .touchUpInside)
        startButton.setTitleColor(UIColor.black, for: .normal)
        startButton.setTitle("Start", for: .normal)
        self.view.addSubview(startButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateResultView()
    }
    
    func updateResultView() {
        resultView.removeFromSuperview()
        resultView = UIView(frame: CGRect(x:0, y:270, width:screenW, height:300))
        self.view.addSubview(resultView)
        
        let row: IntRow? = form.rowBy(tag: "ParticipantID")
        
        if let participantID = row!.value {
            let order = latinSquare[participantID % 6]
            
            for i in 0 ..< 6 {
                let row = UIView(frame: CGRect(x:0, y:CGFloat(i) * 50, width:screenW, height:50))
                let orderLabel = UILabel(frame: CGRect(x:0, y:0, width:50, height:50))
                orderLabel.text = String(order[i])
                orderLabel.textAlignment = .center
                row.addSubview(orderLabel)
                if studyProgress >= i {
                    let resultLabel = UILabel(frame: CGRect(x:50, y:0, width:screenW - 130, height:50))
                    var text = ""
                    let resultList = finalResult.testResultList[i]
                    for result in resultList {
                        text += String(result.1) + ", "
                    }
                    resultLabel.text = text
                    resultLabel.font = UIFont.systemFont(ofSize: 10)
                    resultLabel.numberOfLines = 2
                    row.addSubview(resultLabel)
                    
                    let redoButton = UIButton(frame: CGRect(x:screenW - 80, y:0, width:80, height:50))
                    redoButton.setTitle("Redo", for: .normal)
                    redoButton.setTitleColor(UIColor.red, for: .normal)
                    redoButton.tag = i
                    redoButton.addTarget(self, action: #selector(redoButtonTouched(button:)), for: .touchUpInside)
                    row.addSubview(redoButton)
                }
                
                resultView.addSubview(row)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTestVCFromStudyVC" {
            let vc = segue.destination as! TestVC
            
            let row: IntRow? = form.rowBy(tag: "ParticipantID")
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
    
    func redoButtonTouched(button: UIButton) {
        let tag = button.tag
        self.performSegue(withIdentifier: "showTestVCFromStudyVC", sender: tag)
    }
    
    func startButtonTouched() {
        if finalResult.participantInfo == nil {
            finalResult.participantInfo = form.values()
            print("Participant Info recorded")
        }
        
        if (studyProgress >= 5) {
            let alertController = UIAlertController(title: "All 6 Tests Completed!", message: "", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            studyProgress += 1
            self.performSegue(withIdentifier: "showTestVCFromStudyVC", sender: nil)
        }
    }
}

