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
    
    var index = -1
    var studyCondition: StudyCondition!
    var testOrder = [0, 1, 0, 1]
    var testStep = 0
    
    // (Method, Frequency, TimeInterval)
    var resultList = [(String, Double, Double)]()
    
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
        
        if studyCondition == nil {
            studyCondition = StudyCondition(useReferenceDevice: false, lowAmbientLight: false, lowIntensityLED: false)
        }

        setupStudyCondition()
        
        setupLED()
        
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
    
    func setupStudyCondition() {
        if studyCondition.useReferenceDevice {
            let alertController = UIAlertController(title: "Current Study Condition", message: "ReferenceDevice", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "From Min 1"
                textField.keyboardType = UIKeyboardType.NumberPad
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "From Max 1"
                textField.keyboardType = UIKeyboardType.NumberPad
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "From Min 2"
                textField.keyboardType = UIKeyboardType.NumberPad
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "From Max 2"
                textField.keyboardType = UIKeyboardType.NumberPad
            }

            let saveAction = UIAlertAction(title: "Save", style: .Default) { (_) in
                var results = [(String, Double, Double)]()
                for i in 0 ..< alertController.textFields!.count {
                    let textField = alertController.textFields![i]
                    if textField.text != nil {
                        if let result = Double(textField.text!) {
                            if i%2 == 0 {
                                results.append(("limitsFreqFromMin", result, -1))
                            } else {
                                results.append(("limitsFreqFromMax", result, -1))
                            }
                        } else {
                            results.append(("Wrong", -1, -1))
                        }
                    }
                }
                print(results)
                
                self.saveCSV(results)
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            alertController.addAction(saveAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            var message = "OurDevice, "
            if studyCondition.lowAmbientLight {
                message += "LowAmbient, "
            } else {
                message += "HighAmbient, "
            }
            if studyCondition.lowIntensityLED {
                message += "LowLED"
            } else {
                message += "HighLED"
            }
            
            let alertController = UIAlertController(title: "Current Study Condition", message: message, preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            }
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func setupLED() {
        if studyCondition.lowIntensityLED {
            sendLEDControl(enumLED.lowIntensity.rawValue)
        } else {
            sendLEDControl(enumLED.highIntensity.rawValue)
        }

        turnOffLED()
    }
    
    func turnOffLED() {
        sendLEDControl(1)
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
            sendLEDControl(1)
            bigButton.setTitle("Start Test", forState: UIControlState.Normal)
            
            var result = ("", -1.0, -1.0)
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
            // Update frequency 5 time a second
            limitsTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(0.2, target:self, selector: #selector(self.updateLimitsFromMin), userInfo: nil, repeats: true)
            break
        case 1:
            bigButton.setTitle("Saw Flicker", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light flickers.")
            // Update frequency 5 time a second
            limitsTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(0.2, target:self, selector: #selector(self.updateLimitsFromMax), userInfo: nil, repeats: true)
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
        limitsFreqFromMin += 0.1
        sendFrequency(limitsFreqFromMin)
        print("Current Freq from Min: " + String(limitsFreqFromMin))
    }
    
    func updateLimitsFromMax() {
        if (limitsFreqFromMax < getLimitsMinFreq()) {
            return
        }
        limitsFreqFromMax -= 0.1
        sendFrequency(limitsFreqFromMax)
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
            self.saveCSV(self.resultList)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(saveAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveCSV(resultList: [(String, Double, Double)]) {
        if self.index != -1 {
            finalResult.testResultList[self.index] = resultList
            if let value = finalResult.participantInfo!["ParticipantID"] {
                if let string = value {
                    saveFinalResultToCSV("Result_" + String(string))
                }
            }
        }
    }
    
    
    @IBAction func calibrationLEDButtonTouched(sender: AnyObject) {
        // TODO: Ravi will update this parameter
        print("Calibration LED Button Touched.")
        sendLEDControl(enumLED.calibration.rawValue)
    }
    
    func disconnect(sender: String) {
        print("Disconnecting...")
        RFduinoSingleton.disconnect()
    }
}

