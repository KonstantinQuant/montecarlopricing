import Foundation

enum OptionType {
    case CALL
    case PUT
}

struct EuropeanOption {
    var S: Double /// Spot price
    var T: Double /// Time to expiry
    var r: Double /// Risk-free interest rate
    var sig: Double /// Volatility
    var K: Double /// Strike price
    var type: OptionType /// Type of the option
}


class StandardGaussian {
    let mean: Double = 0.0
    let deviation: Double = 1.0
    
    func nextFloat() -> Double {
        guard deviation > 0 else { return mean }

        let x1 = Double.random(in: 0...1)
        let x2 =  Double.random(in: 0...1)
        let z1 = sqrt(-2 * log(x1)) * cos(2 * Double.pi * x2)
        
        return z1
    }
}


func monteCarlo(nSim: Int, option: EuropeanOption) -> Double {
    var totalPayoff: Double = 0
    var payoffArr: [Double] = []
    for _ in 0 ..< nSim {
        // (21.7) in OPTIONS, FUTURES, AND OTHER DERIVATIVES by John C. Hull
        let epsilon = StandardGaussian().nextFloat()
        let wiener = option.sig * epsilon * sqrt(option.T)
        let euler = exp((option.r - ((option.sig * option.sig) / 2)) * option.T + wiener)
        let price = option.S * euler
        
        if option.type == .CALL {
            payoffArr.append(price)
            
            let currentpayoff = max(price - option.K, 0)
            totalPayoff += currentpayoff
        } else {
            let currentpayoff = max(option.K - price, 0)
            totalPayoff += currentpayoff
        }
    }
    payoffArr.map() { $0 }
    // Discouting the average price
    return (totalPayoff / Double(nSim)) * exp(-option.r * option.T)
}

var nSim = 10000
var callOption = EuropeanOption(S: 60.0, T: 0.25, r: 0.08, sig: 0.3, K: 65.0, type: .CALL)
var putOption =  EuropeanOption(S: 60.0, T: 0.25, r: 0.08, sig: 0.3, K: 65.0, type: .PUT)
var call = monteCarlo(nSim: nSim, option: callOption)
var put = monteCarlo(nSim: nSim, option: putOption)

print("Number of simlations: \(nSim)")
print("Price of the call option: \(call)")
print("Price of the put option: \(put)")
