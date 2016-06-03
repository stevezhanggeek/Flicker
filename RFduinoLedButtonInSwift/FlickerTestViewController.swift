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

    var staircaseFreq_0:Int!
    var staircaseFreq_1:Int!
    var staircaseFreq:Int!
    var staircaseTimerFromMin:NSTimer?
    var staircaseTimerFromMax:NSTimer?

    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        rfduino.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        staircaseFreq_0 = maxFreq
        staircaseFreq_1 = minFreq
    }
    
    func updateLimitsFromMin() {
        sendByte(limitsFreqFromMin)
        limitsFreqFromMin = limitsFreqFromMin + 1
    }

    func updateLimitsFromMax() {
        sendByte(limitsFreqFromMax)
        limitsFreqFromMax = limitsFreqFromMax - 1
    }
    
    func updateStaircaseFromMin() {
        if (abs(staircaseFreq_0-staircaseFreq_1) < 5) {
            staircaseTimerFromMin?.invalidate()
            staircaseTimerFromMax?.invalidate()
            resultLabel.text = "Result: " + String((staircaseFreq_0+staircaseFreq_1)/2) +
                "->" + String(staircaseFreq_0) + "," + String(staircaseFreq_1)
        } else {
            resultLabel.text = "Result: Min = " + String(staircaseFreq)
            sendByte(staircaseFreq)
            staircaseFreq = staircaseFreq + 1
        }
    }
    
    func updateStaircaseFromMax() {
        if (abs(staircaseFreq_0-staircaseFreq_1) < 5) {
            staircaseTimerFromMin?.invalidate()
            staircaseTimerFromMax?.invalidate()
            resultLabel.text = "Result: " + String((staircaseFreq_0+staircaseFreq_1)/2) +
                "->" + String(staircaseFreq_0) + "," + String(staircaseFreq_1)
        } else {
            resultLabel.text = "Result: Max = " + String(staircaseFreq)
            sendByte(staircaseFreq)
            staircaseFreq = staircaseFreq - 1
        }
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
                staircaseFreq_0 = staircaseFreq + 5
                bigButton.setTitle("See Flicker Now", forState: UIControlState.Normal)
                playSound("AudioFlicker")
                staircaseTimerFromMax = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMax), userInfo: nil, repeats: true)
                break
            case 1:
                testStep = 0
                staircaseTimerFromMax?.invalidate()
                staircaseFreq_1 = staircaseFreq - 5
                bigButton.setTitle("Light Steady Now", forState: UIControlState.Normal)
                playSound("AudioSteady")
                staircaseTimerFromMin = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(FlickerTestViewController.updateStaircaseFromMin), userInfo: nil, repeats: true)
                break
            default:
                testStep = 0
                staircaseTimerFromMin?.invalidate()
                staircaseTimerFromMax?.invalidate()
                playSound("AudioResult")
                bigButton.setTitle("Start: Staircase", forState: UIControlState.Normal)
                resultLabel.text = "Result: " + String((staircaseFreq_0+staircaseFreq_1)/2) +
                    "->" + String(staircaseFreq_0) + "," + String(staircaseFreq_1)
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

