# montecarlopricing
Alienating Swift to write a Monte Carlo Simulation Option Pricing application.

# Key Information

Author: Konstantin Kuchenmeister
Read: 5 min

In this article, we'll use Swift to build a Monte Carlo option pricing application. In particular for European options.
Important mathematical basics like Wiener processes are very briefly discussed. Although Swift is not really made for this, this language can also be used for statistics and financial applications. It can be concluded that the runtime does not meet the current requirements, however.
The algorithms used were based on John C. Hull's book on options, futures and other derivatives.

# Introduction
            
"Impress people at cocktail parties with statements like "I have just written a parallel Monte Carlo option pricer in C++17/C++20, with lambdas,futures and variadics"." - Dr. Daniel J. Duffy's 8+1 Reason to learn C++.
Since many quants have already developed a Monte-Carlo Option Pricing Application in C++, we are going to do something similar in Swift today. 
Quite frankly, Swift should not be the language of choice to achieve this, and rightfully so. Swift is not at all designed to be a statistical language and serves a completely different purpose and cannot compare to C++ in terms of runtime.
However, my favorite progamming language can still be misused to write a Monte-Carlo Option Pricing Application. 

# How does Monte Carlo work?
In short, Monte Carlo is a popular numerical method and commonly used for pricing European Options (cannot be exercised before the expiry date).
We are simulating different outcomes of the underlying stock with a technique called random walk, that is achieved through a continuous-time stochastic process called "Wiener Process" or "Brownian Motion".
First, the continuous time interval is first discretized into (fixed) time steps.  At each of the discretized steps, the stock will make a random movement.
To put as it easy as possible: With each simulation a possible, random outcome of the stock is generated using a random value received from the standard normal distribution N(0,1).
We then discount this price back to the current value, and, after enough simulations, the value should converge towards the exact Black-Scholes solution.
This movement has a mean of 0, the generalized Wiener process also features a drift rate, which has the purpose of modeling an expected increase (or loss) different from 0.
The formula looks as follows:

&#x394;x = a*&#x394;t + b*&#x3B5;*&#x221A;(&#x394;t)

where &#x394;t is the size of the discrete subintervals in time, a and b constants, a*&#x394;t the drift rate, and &#x3B5; a random number from standard gaussian distribution.

By, using Ito's Lemma and keeping the volatility of the stock and the drift rate constant we can estimate the price of the derivative with the formula: (See John C. Hull Chapter 21 for proof)

S(T) = S(0) * exp(&#x3BC; - (&#x3C3;^2 * 0.5) *  &#x3C3; * &#x3B5; * &#x221A;(&#x394;t)

where &#x3BC; is the drift rate (equal to the risk-interest rate of the option) and &#x3C3; the volatility.

# Just implement it already!
                
As for the implementation, first, we create a struct that serves as our custom data type for the European Option: 


```swift 
enum OptionType {
    case CALL
    case PUT
}
```

```swift 
struct EuropeanOption {
    var S: Double /// Spot price
    var T: Double /// Time to expiry
    var r: Double /// Risk-free interest rate
    var sig: Double /// Volatility
    var K: Double /// Strike price
    var type: OptionType /// Type of the option
}
```

We now have European Option that can be a call or a put, with a spot price, the maturity, the risk-free interest rate, the volatility and the strike price.
Next, we have to generate a random double, from the standard gaussian distribution with a mean of 0 and a standard deviation of 1.
Therefore, we use the Box–Muller transform since I could not find a better solution in Swift:

```swift 
class StandardGaussian {
    let mean: Double = 0.0
    let deviation: Double = 1.0
    
    func nextDouble() -> Double {
        guard deviation > 0 else { return mean }

        let x1 = Double.random(in: 0...1)
        let x2 =  Double.random(in: 0...1)
        let z1 = sqrt(-2 * log(x1)) * cos(2 * Double.pi * x2)
        
        return z1
    }
}
```
Using the nextDouble() function, we are now able to sample a random double from N(0,1). (Algorithm source: https://en.wikipedia.org/wiki/Box–Muller_transform">https://en.wikipedia.org/wiki/Box–Muller_transform)
With that out of the way, the only thing left to do, is to code up formula 21.7 from John Hull's Book, sum all the outcomes, divide them by the number of iterations and then discount that value back.
```swift 
func monteCarlo(nSim: Int, option: EuropeanOption) -> Double {
    var totalPayoff: Double = 0
    var payoffArr: [Double] = []
    for _ in 0 ..< nSim {
        // (21.7) in OPTIONS, FUTURES, AND OTHER DERIVATIVES by John C. Hull
        let epsilon = StandardGaussian().nextDouble()
        let wiener = option.sig * epsilon * sqrt(option.T)
        let euler = exp((option.r - ((option.sig * option.sig) / 2)) * option.T + wiener)
        let price = option.S * euler
        
        if option.type == .CALL {            
            let currentpayoff = max(price - option.K, 0) // Calculating the payoff of the call option
            totalPayoff += currentpayoff
        } else {
            let currentpayoff = max(option.K - price, 0) // Calculating the payoff of the put option
            totalPayoff += currentpayoff
        }
    }
    // Discouting the average price
    return (totalPayoff / Double(nSim)) * exp(-option.r * option.T)
}
```

We can then test our solution, and compare it to exact values retrieved by the Black-Scholes-Merton formula:

```swift
var nSim = 10000
var callOption = EuropeanOption(S: 60.0, T: 0.25, r: 0.08, sig: 0.3, K: 65.0, type: .CALL)
var putOption =  EuropeanOption(S: 60.0, T: 0.25, r: 0.08, sig: 0.3, K: 65.0, type: .PUT)
var call = monteCarlo(nSim: nSim, option: callOption)
var put = monteCarlo(nSim: nSim, option: putOption)

print("Number of simlations: \(nSim)")
print("Price of the call option: \(call)")
print("Price of the put option: \(put)")
```

```
Output: 
Number of simlations: 10000
Price of the call option: 2.1532795036800905
Price of the put option: 5.896537164267695
```

```
Exact Solution (Black-Scholes-Merton): 
Call price: 2.13337
Put price: 5.84628
```


# What have we learned?

First and foremost, the solution is quite close to the exact solution, but could certainly be increased by increasing the number of simulations to 1 Million or even 10 Million.
This is where Swift has a problem though, this is, computationally very expensive and it will take a couple of minutes on my MBP, which is not feasible.

Coming back to the thumbnail picture, which describes the different stock prices calculated by our random walks, we can see exactly what one would expect. Since we have a mean of zero and a very small drift rate, it is expected to see most of the stock prices ending up around 60$, which was the spot price.
There was one very high outlier of roughly 114, and one with 35. This makes sense, too, since the drift rate is positive, and the random walk is more likely to go up than down.
