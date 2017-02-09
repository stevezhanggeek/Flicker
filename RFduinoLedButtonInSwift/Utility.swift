import Foundation

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
