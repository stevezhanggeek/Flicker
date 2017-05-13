import Foundation
import AVFoundation

/* --------------------Constant-------------------- */
let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
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

enum enumLED : Double {
    case study = 3.0
    case calibration = 5.0
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class StudyCondition {
    var LED = -1
    init(LED: Int) {
        self.LED = LED
    }
    func toString() -> String {
        var string = ""
        if LED == 0 {
            string = "useReferenceDevice"
        } else {
            string = "useOurDevice: LED" + String(LED)
        }
        return string
    }
}

var studyOrder = [0, 1]

let allStudyConditionList = [
    StudyCondition(LED: 0),
    StudyCondition(LED: 1)]

class Result {
    var participantInfo: [String: Any?]?
    var testResultList = [[(String, Double, Double)](),
                          [(String, Double, Double)]()]
}

/* --------------------Helper-------------------- */

func getLimitsMinFreq() -> Double {
    var freq = UserDefaults.standard.double(forKey: "limitsMinFreq")
    if freq <= 0 { freq = 25.0 }
    return freq
}
func setLimitsMinFreq(freq: Double?) {
    if (freq != nil) {
        UserDefaults.standard.set(freq!, forKey: "limitsMinFreq")
    }
}

func getLimitsMaxFreq() -> Double {
    var freq = UserDefaults.standard.double(forKey: "limitsMaxFreq")
    if freq <= 0 { freq = 55.0 }
    return freq
}
func setLimitsMaxFreq(freq: Double?) {
    if (freq != nil) {
        UserDefaults.standard.set(freq!, forKey: "limitsMaxFreq")
    }
}


func fileInDocumentsDirectory(fileName: String) -> String {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    return fileURL.path
}

func saveFinalResultToCSV(fileName: String) {
    let filePath = fileInDocumentsDirectory(fileName: fileName + ".csv")
    var content = ""
    
    if finalResult.participantInfo != nil {
        let fields = ["ParticipantID", "Age", "Gender"]
        for field in fields {
            if let value = finalResult.participantInfo![field] {
                if let string = value {
                    content += String(describing: string) + ","
                }
            }
        }
        content = String(content.characters.dropLast())
        content += "\n"
    }
    
    
    for i in 0 ..< finalResult.testResultList.count {
        var line = allStudyConditionList[studyOrder[i]].toString() + ","
        for entry in finalResult.testResultList[i] {
            line += entry.0 + "," + String(entry.1) + "," + String(entry.2) + ","
        }
        line = String(line.characters.dropLast())
        content += line + "\n"
    }


    do {
        try content.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
    } catch {}
}

func sendToBoard(data: Double) {
    let intX10Data = Int(data*10)
    print(intX10Data)
    var tx: [UInt16] = [UInt16(bitPattern: Int16(intX10Data))]
    let data = NSData(bytes: &tx, length: MemoryLayout<UInt16>.size)
    //RFduinoSingleton.send(data as Data!)
}

func readAloudText(text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.5  // Change speed here.
    speechSynthesizer.speak(utterance)
}

