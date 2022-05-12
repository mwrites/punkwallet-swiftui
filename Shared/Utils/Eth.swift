//
//  Eth.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/29.
//

import Foundation
import BigInt


extension NumberFormatter {
    static func usd(amount: Decimal) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = false
        nf.maximumFractionDigits = 2
        return nf.string(from: NSDecimalNumber(decimal: amount))!
    }
    
    static func ethRoundedToGwei(amount: Decimal) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = false
        nf.maximumFractionDigits = 6
        return nf.string(from: NSDecimalNumber(decimal: amount))!
    }
}


extension String {
    var wei: BigUInt {
        let f = Decimal(string: self) ?? 0
        if f != 0 {
            let wei = f * pow(10, 18)
            return BigUInt(stringLiteral: "\(wei)")
        } else {
            return BigUInt(0)
        }
    }
}

// TODO: why decimals?
//https://stackoverflow.com/questions/3730019/why-not-use-double-or-float-to-represent-currency
//https://www.jessesquires.com/blog/2022/02/01/decimal-vs-double/
extension Decimal {
    func ethToUSD(price: Decimal) -> String {
        return NumberFormatter.usd(amount: self * price)
    }
    
    func usdToEth(price: Decimal) -> String {
        return NumberFormatter.ethRoundedToGwei(amount: self / price)
    }
}


extension BigUInt {
    static let ethDecimals = BigUInt(10).power(18)
    
    var wei: BigUInt {
        return multiplied(by: BigUInt.ethDecimals)
    }
    
    var approxETH: Decimal {
//    https://github.com/argentlabs/web3.swift/issues/112
//        let wei = BigUInt(10000)
//        let eth = wei / BigUInt(10).power(18)
        let div = quotientAndRemainder(dividingBy: BigUInt.ethDecimals)
        
        let q = Decimal(string: String(div.quotient))! + Decimal(string: String(div.remainder))!
        return q / Decimal(string: String(BigUInt.ethDecimals))!
    }
    
    var ethRoundedToGwei: String {
        return NumberFormatter.ethRoundedToGwei(amount: approxETH)
    }
    
    func ethToUSD(price: Decimal) -> String {
        return wei.weiToUSD(price: price)
    }
    
    func weiToUSD(price: Decimal) -> String {
        return NumberFormatter.usd(amount: approxETH * price)
    }
    
    func toETH(price: Decimal) -> String {
        return NumberFormatter.ethRoundedToGwei(amount: approxETH / price)
    }
}
