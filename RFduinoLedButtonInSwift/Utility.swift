import Foundation
import AVFoundation

/* --------------------Constant-------------------- */
let screenW = UIScreen.mainScreen().bounds.width
let screenH = UIScreen.mainScreen().bounds.height
let fullbarH: CGFloat = 64
let navbarH: CGFloat  = 44

/* --------------------Global-------------------- */
var RFduinoSingleton: RFduino!
let speechSynthesizer = AVSpeechSynthesizer()
var thresholdMethod = enumMethod.limits
var studyProgress = 0

/* --------------------Enum-------------------- */

enum enumMethod {
    case limits
    case staircase
    case twoAFC
}

enum enumLED : Int {
    case lowIntensity = 3
    case highIntensity = 4
    case calibration = 5
}

class StudyCondition {
    var useReferenceDevice = false
    var lowAmbientLight = false
    var lowIntensityLED = false
    init(useReferenceDevice: Bool, lowAmbientLight: Bool, lowIntensityLED: Bool) {
        self.useReferenceDevice = useReferenceDevice
        self.lowAmbientLight = lowAmbientLight
        self.lowIntensityLED = lowIntensityLED
    }
    func toString() -> String {
        var string = ""
        if useReferenceDevice {
            string = "useReferenceDevice"
        } else {
            string = "useOurDevice"
            if lowAmbientLight {
                string += "+lowAmbientLight"
            } else {
                string += "+highAmbientLight"
            }
            if lowIntensityLED {
                string += "+lowIntensityLED"
            } else {
                string += "+highIntensityLED"
            }
        }
        return string
    }
}

let allStudyConditionList = [
    StudyCondition(useReferenceDevice: true,  lowAmbientLight: false, lowIntensityLED: false),
    StudyCondition(useReferenceDevice: true,  lowAmbientLight: false, lowIntensityLED: false),
    StudyCondition(useReferenceDevice: false, lowAmbientLight: false, lowIntensityLED: false),
    StudyCondition(useReferenceDevice: false, lowAmbientLight: false, lowIntensityLED: true),
    StudyCondition(useReferenceDevice: false, lowAmbientLight: true,  lowIntensityLED: false),
    StudyCondition(useReferenceDevice: false, lowAmbientLight: true,  lowIntensityLED: true)]


class Result {
    var participantInfo: [String: Any?]?
    var testResultList = [[(String, Int, Double)]]()
}

var finalResult = Result()

/* --------------------Helper-------------------- */

func getLimitsMinFreq() -> Int {
    var freq = NSUserDefaults.standardUserDefaults().integerForKey("limitsMinFreq")
    if freq <= 0 { freq = 25 }
    return freq
}
func setLimitsMinFreq(freq: Int?) {
    if (freq != nil) {
        NSUserDefaults.standardUserDefaults().setInteger(freq!, forKey: "limitsMinFreq")
    }
}

func getLimitsMaxFreq() -> Int {
    var freq = NSUserDefaults.standardUserDefaults().integerForKey("limitsMaxFreq")
    if freq <= 0 { freq = 55 }
    return freq
}
func setLimitsMaxFreq(freq: Int?) {
    if (freq != nil) {
        NSUserDefaults.standardUserDefaults().setInteger(freq!, forKey: "limitsMaxFreq")
    }
}


func fileInDocumentsDirectory(folderName: String, fileName: String) -> String {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    let folderURL = documentsURL.URLByAppendingPathComponent(folderName)
    let fileURL = folderURL!.URLByAppendingPathComponent(fileName)
    return fileURL!.path!
}

func saveFinalResultToCSV(fileName: String) {
    let filePath = fileInDocumentsDirectory("", fileName: fileName + ".csv")
    var content = ""
    
    if finalResult.participantInfo != nil {
        let fields = ["SessionID", "ParticipantID", "StudyDesign", "Age", "Gender"]
        for field in fields {
            if let value = finalResult.participantInfo![field] {
                if let string = value {
                    content += String(string) + ","
                }
            }
        }
        content = String(content.characters.dropLast())
        content += "\n"
    }
    
    for i in 0 ..< finalResult.testResultList.count {
        var line = allStudyConditionList[i].toString() + ","
        for entry in finalResult.testResultList[i] {
            line += entry.0 + "," + String(entry.1) + "," + String(entry.2) + ","
        }
        line = String(line.characters.dropLast())
        content += line + "\n"
    }
    
    do {
        try content.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
    } catch {}
}

func sendByte(byte: Int) {
    var tx: [UInt8] = [UInt8(bitPattern: Int8(byte))]
    let data = NSData(bytes: &tx, length: sizeof(UInt8))
    RFduinoSingleton.send(data)
}

func readAloudText(text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.5  // Change speed here.
    speechSynthesizer.speakUtterance(utterance)
}

