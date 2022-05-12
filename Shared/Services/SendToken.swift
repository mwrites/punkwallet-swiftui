//
//  SendToken.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/16.
//

import Foundation
import web3
import BigInt
import OrderedCollections
import DequeModule
import Combine


class SendToken: ObservableObject {
    let client: EthereumClient
    let account: EthereumAccount
        
    init(client: EthereumClient, account: EthereumAccount) {
        self.client = client
        self.account = account
    }

    func estimateGas(destAds: EthereumAddress, amount: BigUInt, gasLimit: BigUInt = 100000) {
        
    }
    
    func transferEth(destAds: EthereumAddress, amount: BigUInt, gasLimit: BigUInt = 100000) async throws {

        let gasPrice = try! await client.eth_gasPrice()

        let from = account.address
        let to = destAds
        let value = amount
        let nonce = try await client.eth_getTransactionCount(address: account.address, block: .Latest)
        let chainID = client.chainId

        let tx = EthereumTransaction(from: from, to: to, value: value, data: nil, nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, chainId: chainID)
        let txHash = try await client.eth_sendRawTransaction(tx, withAccount: account)

        let sender = CombineNotificationSender(txHash)
        NotificationCenter.default.post(name: CombineNotificationSender.pendingTransactionNotification, object: sender)
    }
}

