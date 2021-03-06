//
//  ViewController.swift
//  RFDuinoLedButtonInSwift
//
//  Created by Cristian Duguet on 9/14/15.
//  Copyright (c) 2015 TrainFES. All rights reserved.
//

import UIKit
import AVFoundation
import ZFRippleButton

class FlickerTestViewController: UIViewController, RFduinoDelegate {
    var rfduino = RFduino()
    let synthesizer = AVSpeechSynthesizer()

    var thresholdMethod = enumMethod.limits
    var testStep = 0
    let maxFreq = 60
    let minFreq = 20
    
    var resultLabel: UILabel!
    var bigButton: UIButton!
    var twoAFCButtons: UIView!
    var twoAFCFirstButton: UIButton!
    var twoAFCSecondButton: UIButton!

    var limitsFreqFromMin:Int!
    var limitsFreqFromMax:Int!
    var limitsTimerFromMin:NSTimer?
    var limitsTimerFromMax:NSTimer?

    var staircaseFreqFromMax:Int!
    var staircaseFreqFromMin:Int!
    var staircaseFreq:Int!
    var staircaseTimerFromMin:NSTimer?
    var staircaseTimerFromMax:NSTimer?
    
    let twoAFCTestCount = 5
    var twoAFCResults = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        rfduino.delegate = self
        
        readAloudText("")
        
        twoAFCResults = [Int](count: twoAFCTestCount, repeatedValue: 0)
        print(twoAFCResults)
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Method", style: .Plain, target: self, action: #selector(self.methodButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingIcon"), style: .Plain, target: self, action: #selector(self.settingsButtonTouched))

        bigButton = ZFRippleButton(frame: self.view.frame)
        bigButton.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
        bigButton.addTarget(self, action: #selector(self.bigButtonTouched), forControlEvents: .TouchUpInside)
        bigButton.hidden = true
        self.view.addSubview(bigButton)

        twoAFCButtons = UIView(frame: self.view.frame)
        twoAFCButtons.hidden = true
        self.view.addSubview(twoAFCButtons)

        twoAFCFirstButton  = ZFRippleButton(frame: CGRectMake(0, 0, twoAFCButtons.frame.width, twoAFCButtons.frame.height/2))
        twoAFCSecondButton = ZFRippleButton(frame: CGRectMake(0, twoAFCButtons.frame.height/2, twoAFCButtons.frame.width, twoAFCButtons.frame.height/2))
        twoAFCFirstButton.backgroundColor  = UIColor.lightGrayColor()
        twoAFCSecondButton.backgroundColor = UIColor.darkGrayColor()
        twoAFCFirstButton.addTarget(self,  action: #selector(self.twoAFCFirstButtonTouched),  forControlEvents: .TouchUpInside)
        twoAFCSecondButton.addTarget(self, action: #selector(self.twoAFCSecondButtonTouched), forControlEvents: .TouchUpInside)
        twoAFCButtons.addSubview(twoAFCFirstButton)
        twoAFCButtons.addSubview(twoAFCSecondButton)

        resultLabel = UILabel(frame: self.view.frame)
        resultLabel.hidden = true
        self.view.addSubview(resultLabel)
    }
    
    func disconnect(sender: String) {
        print("Disconnecting...")
        rfduino.disconnect()
    }
    
    func sendByte(byte: Int) {
        var tx: [UInt8] = [UInt8(bitPattern: Int8(byte))]
        let data = NSData(bytes: &tx, length: sizeof(UInt8))
        rfduino.send(data)
    }
    
    func settingsButtonTouched() {
        self.performSegueWithIdentifier("gotoSettings", sender: nil)

//        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func resetAll() {
        staircaseTimerFromMin?.invalidate()
        staircaseTimerFromMax?.invalidate()
        limitsTimerFromMin?.invalidate()
        limitsTimerFromMax?.invalidate()
        testStep = 0
        bigButton.hidden = true
        twoAFCButtons.hidden = true
        resultLabel.text = ""
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Method", style: .Plain, target: self, action: #selector(self.methodButtonTouched))
        
        sendByte(1)
    }
    
    func stopButtonTouched() {
        resetAll()
    }
    
    func methodButtonTouched() {
        let alertController = UIAlertController(title: "Which method would you like to choose?", message: "", preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Limits", style: .Default) { (action) in
            self.resetAll()
            self.thresholdMethod = enumMethod.limits
            self.bigButton.hidden = false
            self.bigButton.setTitle("Start (Limits)", forState: UIControlState.Normal)
            self.limitsFreqFromMin = self.minFreq
            self.limitsFreqFromMax = self.maxFreq
            self.navigationItem.title = "Limits"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(self.stopButtonTouched))
            })
        alertController.addAction(UIAlertAction(title: "Staircase", style: .Default) { (action) in
            self.resetAll()
            self.thresholdMethod = enumMethod.staircase
            self.bigButton.hidden = false
            self.bigButton.setTitle("Start", forState: UIControlState.Normal)
            self.staircaseFreq = self.maxFreq
            self.staircaseFreqFromMax = self.maxFreq
            self.staircaseFreqFromMin = self.minFreq
            self.navigationItem.title = "Staircase"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(self.stopButtonTouched))
            })
        alertController.addAction(UIAlertAction(title: "2AFC", style: .Default) { (action) in
            self.resetAll()
            self.thresholdMethod = enumMethod.twoAFC
            self.bigButton.hidden = false
            self.bigButton.setTitle("Start", forState: UIControlState.Normal)
            self.navigationItem.title = "2AFC"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(self.stopButtonTouched))
            })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateLimitsFromMin() {
        print("Current Freq from Min: " + String(limitsFreqFromMin))
        if (limitsFreqFromMin > maxFreq) {
            return
        }
        sendByte(limitsFreqFromMin)
        limitsFreqFromMin = limitsFreqFromMin + 1
    }

    func updateLimitsFromMax() {
        print("Current Freq from Max: " + String(limitsFreqFromMax))
        if (limitsFreqFromMax < minFreq) {
            return
        }
        sendByte(limitsFreqFromMax)
        limitsFreqFromMax = limitsFreqFromMax - 1
    }
    
    func updateStaircaseFromMin() {
        print("Result: Min = " + String(staircaseFreq))
        sendByte(staircaseFreq)
        staircaseFreq = staircaseFreq + 1
    }
    
    func updateStaircaseFromMax() {
        print("Result: Max = " + String(staircaseFreq))
        sendByte(staircaseFreq)
        staircaseFreq = staircaseFreq - 1
    }
    
    func readAloudText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // Change speed here.
        utterance.rate = 0.5
        synthesizer.speakUtterance(utterance)
    }
    
    func processLimitsTest() {
        switch testStep {
        case 0:
            testStep += 1
            bigButton.setTitle("Light Steady Now", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light is steady.")
            limitsTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateLimitsFromMin), userInfo: nil, repeats: true)
            break
        case 1:
            testStep += 1
            limitsTimerFromMin?.invalidate()
            bigButton.setTitle("See Flicker Now", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light flickers.")
            limitsTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateLimitsFromMax), userInfo: nil, repeats: true)
            break
        default:
            resetAll()
            readAloudText("Please check result on screen.")
            resultLabel.hidden = false
            resultLabel.text = "Result: Min = " + String(limitsFreqFromMin) + ", Max = " + String(limitsFreqFromMax)
            self.navigationItem.title = "Results(Limits)"
            break
        }
    }
    
    func processStaircaseTest() {
        switch testStep {
        case 0:
            resetAll()
            testStep = 1
            staircaseTimerFromMin?.invalidate()
            
            if (abs(staircaseFreq-staircaseFreqFromMin) <= 5) {
                staircaseTimerFromMin?.invalidate()
                staircaseTimerFromMax?.invalidate()
                print("Result: " + String((staircaseFreq+staircaseFreqFromMin)/2) +
                    "->" + String(staircaseFreq) + "," + String(staircaseFreqFromMin))
                testStep = -1
                return
            }
            
            staircaseFreqFromMax = staircaseFreq
            staircaseFreq = staircaseFreq + 5
            bigButton.setTitle("See Flicker Now", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light flickers.")
            staircaseTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMax), userInfo: nil, repeats: true)
            break
        case 1:
            testStep = 0
            staircaseTimerFromMax?.invalidate()
            
            if (abs(staircaseFreqFromMax-staircaseFreq) <= 5) {
                staircaseTimerFromMin?.invalidate()
                staircaseTimerFromMax?.invalidate()
                print("Result: " + String((staircaseFreqFromMax+staircaseFreq)/2) +
                    "->" + String(staircaseFreqFromMax) + "," + String(staircaseFreq))
                testStep = -1
                return
            }
            
            staircaseFreqFromMin = staircaseFreq
            staircaseFreq = staircaseFreq - 5
            bigButton.setTitle("Light Steady Now", forState: UIControlState.Normal)
            readAloudText("Touch screen when the light is steady.")
            staircaseTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMin), userInfo: nil, repeats: true)
            break
        default:
            resetAll()
            readAloudText("Please check result on screen.")
            print("Result: " + String((staircaseFreqFromMax+staircaseFreqFromMin)/2) +
                "->" + String(staircaseFreqFromMax) + "," + String(staircaseFreqFromMin))
            self.navigationItem.title = "Results(Staircase)"
            break
        }
    }
    
    func processTwoAFCTest() {
        if (testStep < twoAFCTestCount - 1) {
            testStep += 1
            self.navigationItem.title = String(testStep+1) + "/" + String(twoAFCTestCount)
        } else {
            resetAll()
            readAloudText("Please check result on screen.")
            resultLabel.hidden = false
            var resultString = ""
            for result in twoAFCResults {
                resultString += (String(result) + " ")
            }
            resultLabel.text = resultString
            self.navigationItem.title = "Results(2AFC)"
        }
    }
    
    func twoAFCFirstButtonTouched() {
        twoAFCResults[testStep] = 1
        processTwoAFCTest()
    }

    func twoAFCSecondButtonTouched() {
        twoAFCResults[testStep] = 2
        processTwoAFCTest()
    }

    func bigButtonTouched() {
        switch thresholdMethod {
        case .limits:
            processLimitsTest()
            break
        case .staircase:
            processStaircaseTest()
            break
        case .twoAFC:
            bigButton.hidden = true
            twoAFCButtons.hidden = false
            twoAFCFirstButton.setTitle("The first light flickers",   forState: UIControlState.Normal)
            twoAFCSecondButton.setTitle("The second light flickers", forState: UIControlState.Normal)
            self.navigationItem.title = "1/" + String(twoAFCTestCount)
            break
        }
    }
    
    /* // Button is not stable yet...
    func didReceive(data: NSData!) {
        print("Received Data")
        print(data)
        var value : [UInt8] = [0]
        data.getBytes(&value, length: 1)
        if (value[0] == 0) {
            print("step")
            stepProgress()
        }
    }
     */
}

