import Foundation
import UIKit
import MessageUI

class SettingsVC: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var limitsMinFreqTextField: UITextField!
    @IBOutlet weak var limitsMaxFreqTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        
        limitsMinFreqTextField.text = String(getLimitsMinFreq())
        limitsMaxFreqTextField.text = String(getLimitsMaxFreq())
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        setLimitsMinFreq(Double(limitsMinFreqTextField.text!))
        setLimitsMaxFreq(Double(limitsMaxFreqTextField.text!))
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
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    
}
