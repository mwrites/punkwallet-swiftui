////
////  Transactions.swift
////  punkwallet
////
////  Created by mwrites on 2022/4/16.
////
//
//import Foundation
//import web3
//import BigInt
//import OrderedCollections
//import DequeModule
//import Resolver
//
//
//class TransactionManager: ObservableObject {
//    
//    @Published var transactions: OrderedDictionary<String, EthereumTransactionReceiptStatus> = [:]
//    private var pendingTransactionsQ: Deque<String> = Deque()
//    
//    // TODO: weak??
//    @InjectedObject var walletSync: WalletSync
//    @InjectedObject var walletProvider: WalletManager
//    
//    // proxies
//    var client: EthereumClient {
//        let rpcUrl = Config.rpcRinkeby
//    
//        let clientUrl = URL(string: rpcUrl)!
//        return EthereumClient(url: clientUrl)
//    }
//    var account: EthereumAccount { return walletManager.account }
//    
//        
//    func transfer(fromAds: String, toAds: String, amount: BigUInt) async {
//        
//        let gasPrice = try! await client.eth_gasPrice()
//        
//        
//        // TODO: ???
//        let nonce = 9
//        // TODO: fixme! how to use estimate gas?
//        let gasLimit = BigUInt(100000)
//        // for estimating gas
////        let mockTx = EthereumTransaction(from: from, to: to, value: value, data: nil, nonce: nonce, gasPrice: 0, gasLimit: 0, chainId: chainID)
////        let gas = try! await client.eth_estimateGas(mockTx, withAccount: account)
//        
//        
//        
//        let from = EthereumAddress(fromAds)
//        let to = EthereumAddress(toAds)
//        let value = amount
////        let chainID = client.network!.intValue
//        let chainID = 4
//        
//        
//      
//        let tx = EthereumTransaction(from: from, to: to, value: value, data: nil, nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, chainId: chainID)
//        let txHash = try! await client.eth_sendRawTransaction(tx, withAccount: account)
//        
//        
//      
//        pendingTransactionsQ.append(txHash)
//        transactions[txHash] = EthereumTransactionReceiptStatus.notProcessed
//        
////        let receipt = try? await client.eth_getTransactionReceipt(txHash: txHash)
////        print(receipt)
//        
//        
//        
//        
////        let account = try! EthereumAccount.init(keyStorage: TestEthereumKeyStorage(privateKey: "0x4646464646464646464646464646464646464646464646464646464646464646"))
////        let signed = try! account.sign(transaction: tx)
////
////        let v = signed.v.web3.hexString
////        let r = signed.r.web3.hexString
////        let s = signed.s.web3.hexString
////
////        XCTAssertEqual(v, "0x25")
////        XCTAssertEqual(r, "0x28ef61340bd939bc2195fe537567866003e1a15d3c71ff63e1590620aa636276")
////        XCTAssertEqual(s, "0x67cbe9d8997f761aecb703304b3800ccf555c9f3dc64214b297fb1966a3b6d83")
//    }
//    
//    func updateTransactionsStatus() async {
//        guard pendingTransactionsQ.count > 0 else { return }
//         
//        // clear the succeeding transactions from the pendingTransactionsQ
//        
//        var succeedingTxs = [Int]()
//        
//        for (i, tx) in pendingTransactionsQ.enumerated() {
//            do {
//                let receipt = try await client.eth_getTransactionReceipt(txHash: tx)
//                print("Transaction Receipt: \(receipt)")
//                transactions[tx] = receipt.status
//                
//                switch receipt.status {
//                case .success:
//                    succeedingTxs.append(i)
//                case .failure:
//                    print("updateTransactionsStatus: Failing Transaction: PLS DO SOMETHING!!! ")
//                case .notProcessed:
//                    break
//                }
//
//            } catch {
//                print("Error: updateTransactionsStatus - \(error)")
//            }
//        }
//        
//
//        pendingTransactionsQ.remove(atOffsets: IndexSet(succeedingTxs))
//    }
//}
