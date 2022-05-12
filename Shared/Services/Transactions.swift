//
//  Transactions.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/11.
//

import Foundation
import web3
import BigInt
import OrderedCollections
import DequeModule
import Combine


class Transactions: ObservableObject {
    @Published var transactions: OrderedDictionary<String, EthereumTransactionReceiptStatus> = [:]
    
    private var pendingTransactionsQ: Deque<String> = Deque()
    let client: EthereumClient
    
    var walletSyncListener: WalletSyncListener!
    var pendingTransactionListener: PendingTransactionListener!
    
    
    init(client: EthereumClient) {
        self.client = client
        
        initListeners()
    }
    
    func initListeners() {
        walletSyncListener = WalletSyncListener() {
            print("walletSyncListener: \($0)")
            Task { [weak self] in
                await self?.updateTransactionsStatus()
            }
        }
        
        pendingTransactionListener = PendingTransactionListener() { [weak self] in
            print("pendingTransactionListener: \($0)")
            self?.pendingTransactionsQ.append($0)
            self?.transactions[$0] = EthereumTransactionReceiptStatus.notProcessed
        }
    }


    func updateTransactionsStatus() async {
        // TODO: persist and fetch back pendingTransactions?
        guard pendingTransactionsQ.count > 0 else { return }

        // clear the succeeding transactions from the pendingTransactionsQ
        var succeedingTxs = [Int]()
        
        // TODO: is a dispatch group necessary?
        for (i, tx) in pendingTransactionsQ.enumerated() {
            do {
                let receipt = try await client.eth_getTransactionReceipt(txHash: tx)
                print("Transaction Receipt: \(receipt)")
                transactions[tx] = receipt.status

                switch receipt.status {
                case .success:
                    LocalNotifications.shared.sendNotification(title: receipt.status.stringValue, body: tx)
                    succeedingTxs.append(i)
                case .failure:
                    // TODO: this can quickly become annoying because of the loop
                    let msg = "Failing Transaction: \(tx): \(receipt)"
                    let error = NSError(domain: Config.stringWithAppID("updateTransactionsStatus.error"), code: 42, userInfo: [NSLocalizedDescriptionKey:msg])
                    print("updateTransactionsStatus: Failing Transaction! \(error)")
                    ErrorPublisher.shared.setError(error)
                case .notProcessed:
                    break
                }

            } catch {
                print("Error: updateTransactionsStatus - \(error)")
            }
        }
        pendingTransactionsQ.remove(atOffsets: IndexSet(succeedingTxs))
    }
}


extension EthereumTransactionReceiptStatus {
    var stringValue: String {
        switch self {
        case .success:
            return "success"
        case .failure:
            return "failure"
        case .notProcessed:
            return "pending"
        }
    }
}
