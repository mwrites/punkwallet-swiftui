//
//  EthereumClient+Helpers.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/20.
//

import web3


extension EthereumClient {
    // Because EthereumNetwork.intValue is not public
    var chainId: Int {
        switch network {
        case .Mainnet:
            return 1
        case .Ropsten:
            return 3
        case .Rinkeby:
            return 4
        case .Kovan:
            return 42
        case .Custom(let str):
            return Int(str) ?? 0
        default:
            return 0
        }
    }
}
