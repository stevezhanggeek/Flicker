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
var studyProgress = -1
var finalResult = Result()

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

let latinSquare = [
    [0,1,5,2,4,3],
    [1,2,0,3,5,4],
    [2,3,1,4,0,5],
    [3,4,2,5,1,0],
    [4,5,3,0,2,1],
    [5,0,4,1,3,2]
]

class Result {
    var participantInfo: [String: Any?]?
    var testResultList = [[(String, Double, Double)](),
                          [(String, Double, Double)](),
                          [(String, Double, Double)](),
                          [(String, Double, Double)](),
                          [(String, Double, Double)](),
                          [(String, Double, Double)]()]
}

/* --------------------Helper-------------------- */

func getLimitsMinFreq() -> Double {
    var freq = NSUserDefaults.standardUserDefaults().doubleForKey("limitsMinFreq")
    if freq <= 0 { freq = 25.0 }
    return freq
}
func setLimitsMinFreq(freq: Double?) {
    if (freq != nil) {
        NSUserDefaults.standardUserDefaults().setDouble(freq!, forKey: "limitsMinFreq")
    }
}

func getLimitsMaxFreq() -> Double {
    var freq = NSUserDefaults.standardUserDefaults().doubleForKey("limitsMaxFreq")
    if freq <= 0 { freq = 55.0 }
    return freq
}
func setLimitsMaxFreq(freq: Double?) {
    if (freq != nil) {
        NSUserDefaults.standardUserDefaults().setDouble(freq!, forKey: "limitsMaxFreq")
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
        let fields = ["ParticipantID", "Age", "Gender"]
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
    
    
    if let value = finalResult.participantInfo!["ParticipantID"] {
        if let id = value {
            let order = latinSquare[Int(String(id))! % 6]
            
            for i in 0 ..< finalResult.testResultList.count {
                var line = allStudyConditionList[order[i]].toString() + ","
                for entry in finalResult.testResultList[i] {
                    line += entry.0 + "," + String(entry.1) + "," + String(entry.2) + ","
                }
                line = String(line.characters.dropLast())
                content += line + "\n"
            }
        }
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

func sendToBoard(data: Double) {
    let intX10Data = Int(data*10)
    print(intX10Data)
    var tx: [UInt16] = [UInt16(bitPattern: Int16(intX10Data))]
    let data = NSData(bytes: &tx, length: sizeof(UInt16))
    RFduinoSingleton.send(data)
}

/*
func sendToBoard(data: Double) {
    let int10Data = Int(data*10)
    var tx: [UInt16] = [UInt16(bitPattern: Int16(int10Data))]
    let data = NSData(bytes: &tx, length: sizeof(UInt16))
    RFduinoSingleton.send(data)
}
 */

func readAloudText(text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.5  // Change speed here.
    speechSynthesizer.speakUtterance(utterance)
}

