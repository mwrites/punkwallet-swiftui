//
//  Token.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/3.
//

import Foundation
import BigInt


struct Token: Hashable {
    static let placeholder = Token(logo: "coin_eth", name: "Ether", currency: "ETH")
    
    
    let logo: String
    let name: String
    let currency: String

    // TODO: should probably move the below 2 outside to sthing liek a balance and make token a struct
    // in wei (or the smallest unit)
    var amount: BigUInt = 0
    var pricePerToken: Decimal = 0
    
    var tokenDisplay: String {
        return amount.ethRoundedToGwei + " " + currency
    }
    
    var usdDisplay: String {
        return amount.weiToUSD(price: pricePerToken) + " USD"
    }
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        return lhs.amount == rhs.amount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(amount.hashValue)
    }
}
