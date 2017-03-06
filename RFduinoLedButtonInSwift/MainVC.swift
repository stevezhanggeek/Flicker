import UIKit

class MainVC: UIViewController {
    var rfduino: RFduino!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RFduinoSingleton = rfduino
    }
}

