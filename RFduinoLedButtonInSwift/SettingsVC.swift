import Foundation
import UIKit
import MessageUI

class SettingsVC: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var limitsMinFreqTextField: UITextField!
    @IBOutlet weak var limitsMaxFreqTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        limitsMinFreqTextField.text = String(getLimitsMinFreq())
        limitsMaxFreqTextField.text = String(getLimitsMaxFreq())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setLimitsMinFreq(freq: Double(limitsMinFreqTextField.text!))
        setLimitsMaxFreq(freq: Double(limitsMaxFreqTextField.text!))
    }
    
    @IBAction func sendEmailButtonTouched(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setToRecipients(["xiaoyiz@cs.washington.edu", "rkarkar@cs.washington.edu"])
            if let value = finalResult.participantInfo!["ParticipantID"] {
                if let id = value {
                    mailComposer.setSubject("[FlickerUserStudy] "+"Participant " + String(describing: id))
                    mailComposer.setMessageBody("CSV file is attached.", isHTML: false)
                    let filePath = fileInDocumentsDirectory(fileName: "Result_" + String(describing: id)+"_"+String(describing: finalResult.participantInfo!["Age"]!!) + ".csv")
                    if let contents = try? String(contentsOfFile: filePath) {
                        let data = contents.data(using: String.Encoding.utf8, allowLossyConversion: false)
                        mailComposer.addAttachmentData(data!, mimeType: "text/csv", fileName: "Results_" + String(describing: id) + "_"+String(describing: finalResult.participantInfo!["Age"]!!) + ".csv")
                    }
                }
            }
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
