import UIKit

class MainVC: UIViewController {
    var rfduino: RFduino!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RFduinoSingleton = rfduino
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTestVC" {
            let vc = segue.destination as! TestVC
            vc.testOrder = [0, 1, 0, 1]
        }
    }    
}

