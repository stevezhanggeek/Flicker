//
//  ViewController.swift
//  RFDuinoLedButtonInSwift
//
//  Created by Cristian Duguet on 9/14/15.
//  Copyright (c) 2015 TrainFES. All rights reserved.
//

import UIKit
import AudioToolbox

class FlickerTestViewController: UIViewController, RFduinoDelegate {
    var rfduino = RFduino()
    
    var thresholdMethod = "Limits"
    var testStep = 0
    let maxFreq = 60
    let minFreq = 20
    
    var limitsFreqFromMin:Int!
    var limitsFreqFromMax:Int!
    var limitsTimerFromMin:NSTimer?
    var limitsTimerFromMax:NSTimer?

    var staircaseFreqFromMax:Int!
    var staircaseFreqFromMin:Int!
    var staircaseFreq:Int!
    var staircaseTimerFromMin:NSTimer?
    var staircaseTimerFromMax:NSTimer?

    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        rfduino.delegate = self
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Method", style: .Plain, target: self, action: #selector(self.methodButtonTouched))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingIcon"), style: .Plain, target: self, action: #selector(self.settingsButtonTouched))
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
    
    func methodButtonTouched() {
        let alertController = UIAlertController(title: "", message: "Which method would you like to choose?", preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Limits", style: .Default) { (action) in
            })
        alertController.addAction(UIAlertAction(title: "Staircase", style: .Default) { (action) in
            })
        alertController.addAction(UIAlertAction(title: "2AFC", style: .Default) { (action) in
            })
        self.presentViewController(alertController, animated: true, completion: nil)

    }

    @IBAction func LimitsButtonTouched(sender: AnyObject) {
        thresholdMethod = "Limits"
        bigButton.setTitle("Start: Limits", forState: UIControlState.Normal)
        limitsFreqFromMin = minFreq
        limitsFreqFromMax = maxFreq
    }
    
    @IBAction func StaircaseButtonTouched(sender: AnyObject) {
        thresholdMethod = "Staircase"
        bigButton.setTitle("Start: Staircase", forState: UIControlState.Normal)
        staircaseFreq = maxFreq
        staircaseFreqFromMax = maxFreq
        staircaseFreqFromMin = minFreq
    }
    
    func updateLimitsFromMin() {
        resultLabel.text = "Current Freq from Min: " + String(limitsFreqFromMin)
        sendByte(limitsFreqFromMin)
        limitsFreqFromMin = limitsFreqFromMin + 1
    }

    func updateLimitsFromMax() {
        resultLabel.text = "Current Freq from Max: " + String(limitsFreqFromMax)
        sendByte(limitsFreqFromMax)
        limitsFreqFromMax = limitsFreqFromMax - 1
    }
    
    func updateStaircaseFromMin() {
        resultLabel.text = "Result: Min = " + String(staircaseFreq)
        sendByte(staircaseFreq)
        staircaseFreq = staircaseFreq + 1
    }
    
    func updateStaircaseFromMax() {
        resultLabel.text = "Result: Max = " + String(staircaseFreq)
        sendByte(staircaseFreq)
        staircaseFreq = staircaseFreq - 1
    }
    
    func playSound(soundName: String) {
        if let soundURL = NSBundle.mainBundle().URLForResource(soundName, withExtension: "mp3") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL, &mySound)
            AudioServicesPlaySystemSound(mySound);
        }
    }
    
    func stepProgress() {
        if (thresholdMethod == "Limits") {
            switch testStep {
            case 0:
                testStep += 1
                bigButton.setTitle("Light Steady Now", forState: UIControlState.Normal)
                playSound("AudioSteady")
                limitsTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateLimitsFromMin), userInfo: nil, repeats: true)
                break
            case 1:
                testStep += 1
                limitsTimerFromMin?.invalidate()
                bigButton.setTitle("See Flicker Now", forState: UIControlState.Normal)
                playSound("AudioFlicker")
                limitsTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateLimitsFromMax), userInfo: nil, repeats: true)
                break
            default:
                testStep = 0
                limitsTimerFromMax?.invalidate()
                //sendByte(-1)
                playSound("AudioResult")
                bigButton.setTitle("Start: Limits", forState: UIControlState.Normal)
                resultLabel.text = "Result: Min = " + String(limitsFreqFromMin) + ", Max = " + String(limitsFreqFromMax)
                break
            }
        } else if (thresholdMethod == "Staircase") {
            switch testStep {
            case 0:
                testStep = 1
                staircaseTimerFromMin?.invalidate()
                
                if (abs(staircaseFreq-staircaseFreqFromMin) <= 5) {
                    staircaseTimerFromMin?.invalidate()
                    staircaseTimerFromMax?.invalidate()
                    resultLabel.text = "Result: " + String((staircaseFreq+staircaseFreqFromMin)/2) +
                        "->" + String(staircaseFreq) + "," + String(staircaseFreqFromMin)
                    testStep = -1
                    return
                }
                
                staircaseFreqFromMax = staircaseFreq
                staircaseFreq = staircaseFreq + 5
                bigButton.setTitle("See Flicker Now", forState: UIControlState.Normal)
                playSound("AudioFlicker")
                staircaseTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMax), userInfo: nil, repeats: true)
                break
            case 1:
                testStep = 0
                staircaseTimerFromMax?.invalidate()
                
                if (abs(staircaseFreqFromMax-staircaseFreq) <= 5) {
                    staircaseTimerFromMin?.invalidate()
                    staircaseTimerFromMax?.invalidate()
                    resultLabel.text = "Result: " + String((staircaseFreqFromMax+staircaseFreq)/2) +
                        "->" + String(staircaseFreqFromMax) + "," + String(staircaseFreq)
                    testStep = -1
                    return
                }
                
                staircaseFreqFromMin = staircaseFreq
                staircaseFreq = staircaseFreq - 5
                bigButton.setTitle("Light Steady Now", forState: UIControlState.Normal)
                playSound("AudioSteady")
                staircaseTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMin), userInfo: nil, repeats: true)
                break
            default:
                testStep = 0
                staircaseTimerFromMin?.invalidate()
                staircaseTimerFromMax?.invalidate()
                playSound("AudioResult")
                bigButton.setTitle("Start: Staircase", forState: UIControlState.Normal)
                resultLabel.text = "Result: " + String((staircaseFreqFromMax+staircaseFreqFromMin)/2) +
                    "->" + String(staircaseFreqFromMax) + "," + String(staircaseFreqFromMin)
                break
            }
        }
    }
    
    @IBAction func BigButtonTouched(sender: AnyObject) {
        stepProgress()
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

