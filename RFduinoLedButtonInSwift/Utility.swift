import Foundation
import AVFoundation

/* --------------------Constant-------------------- */

/* --------------------Global-------------------- */
var RFduinoSingleton: RFduino!
let speechSynthesizer = AVSpeechSynthesizer()
var thresholdMethod = enumMethod.limits

/* --------------------Enum-------------------- */

enum enumMethod {
    case limits
    case staircase
    case twoAFC
}

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


func writeToCSV(fileName: String, frequencyList: [Int]) {
    let wordList = fileInDocumentsDirectory("", fileName: fileName + ".csv")
    var file = ""
    for frequency in frequencyList {
        file.appendContentsOf(String(frequency) + "\n")
    }
    do {
        try file.writeToFile(wordList, atomically: false, encoding: NSUTF8StringEncoding)
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

