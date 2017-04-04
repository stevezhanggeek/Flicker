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
    
    @IBAction func sendEmailButtonTouched(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setToRecipients(["xiaoyiz@cs.washington.edu", "rkarkar@cs.washington.edu"])
            mailComposer.setSubject("[FlickerUserStudy] "+"Participant 1")
            mailComposer.setMessageBody("CSV file is attached.", isHTML: false)
            /*
            if let filePath = NSBundle.mainBundle().pathForResource("swifts", ofType: "wav") {
                if let fileData = NSData(contentsOfFile: filePath) {
                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "swifts")
                }
            }
 */
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    
}
