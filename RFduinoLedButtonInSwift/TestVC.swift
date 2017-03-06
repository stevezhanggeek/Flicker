import UIKit
import AVFoundation
import ZFRippleButton

class TestVC: UIViewController, RFduinoDelegate {
    var bigButton: UIButton!
    
    var limitsFreqFromMin = getLimitsMinFreq()
    var limitsFreqFromMax = getLimitsMaxFreq()
    var limitsTimerFromMin:NSTimer?
    var limitsTimerFromMax:NSTimer?
    
    var pauseFlag = false
    var lastTimestamp = NSDate()
    
    var testOrder = [0, 1, 1, 0]
    var testStep = 0
    
    // (Method, Frequency, TimeInterval)
    var resultList = [(String, Int, Double)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        RFduinoSingleton.delegate = self
        
        bigButton = ZFRippleButton(frame: self.view.frame)
        bigButton.titleLabel?.font = UIFont.boldSystemFontOfSize(35)
        bigButton.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 1)
        bigButton.addTarget(self, action: #selector(self.bigButtonTouched), forControlEvents: .TouchUpInside)
        self.view.addSubview(bigButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        sendByte(3)
        sendByte(1)
        
        bigButton.setTitle("Start Test", forState: UIControlState.Normal)
        
        resultList.removeAll()
        
        for _ in 0 ..< testOrder.count {
            resultList.append(("", -1, -1))
        }
        
        reset()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resultList.removeAll()
        reset()
    }
    
    func reset() {
        limitsFreqFromMin = getLimitsMinFreq()
        limitsFreqFromMax = getLimitsMaxFreq()
        limitsTimerFromMin?.invalidate()
        limitsTimerFromMax?.invalidate()
    }
    
    func processLimitsTest() {
        if pauseFlag {
            pauseFlag = false

            // Stop LED
            sendByte(1)
            bigButton.setTitle("Start Test", forState: UIControlState.Normal)
            
            var result = ("", -1, -1.0)
            if testOrder[testStep - 1] == 0 {
                result.0 = "limitsFreqFromMin"
                result.1 = limitsFreqFromMin
                result.2 = Double(NSDate().timeIntervalSinceDate(lastTimestamp))
            } else {
                result.0 = "limitsFreqFromMax"
                result.1 = limitsFreqFromMax
                result.2 = Double(NSDate().timeIntervalSinceDate(lastTimestamp))
            }
            resultList[testStep - 1] = result
            
            if testStep == testOrder.count {
                reset()
                testCompleted()
                return
            }
            
            reset()
            return
        }
        
        if testStep >= testOrder.count { return }

        reset()

        lastTimestamp = NSDate()
        switch testOrder[testStep] {
        case 0:
            bigButton.setTitle("Saw Steady Light", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light is steady.")
            limitsTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(self.updateLimitsFromMin), userInfo: nil, repeats: true)
            break
        case 1:
            bigButton.setTitle("Saw Flicker", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light flickers.")
            limitsTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(self.updateLimitsFromMax), userInfo: nil, repeats: true)
            break
        default:
            break
        }

        pauseFlag = true
        testStep += 1
    }
    
    func bigButtonTouched() {
        processLimitsTest()
    }
    
    func updateLimitsFromMin() {
        if (limitsFreqFromMin > getLimitsMaxFreq()) {
            return
        }
        limitsFreqFromMin += 1
        sendByte(limitsFreqFromMin)
        print("Current Freq from Min: " + String(limitsFreqFromMin))
    }
    
    func updateLimitsFromMax() {
        if (limitsFreqFromMax < getLimitsMinFreq()) {
            return
        }
        limitsFreqFromMax -= 1
        sendByte(limitsFreqFromMax)
        print("Current Freq from Max: " + String(limitsFreqFromMax))
    }
    
    func testCompleted() {
        print(resultList)
        
        var message = "Your results:\n"
        for result in resultList {
            message += result.0 + ", " + String(result.1) + ", " + String(round(100*result.2)/100) + "\n"
        }
        
        let alertController = UIAlertController(title: "Test Completed!", message: message, preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(saveAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func calibrationLEDButtonTouched(sender: AnyObject) {
        // TODO: Ravi will update this parameter
        print("Calibration LED Button Touched.")
    }
    
    func disconnect(sender: String) {
        print("Disconnecting...")
        RFduinoSingleton.disconnect()
    }
}

