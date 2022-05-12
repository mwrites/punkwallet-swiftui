//
//  WalletSync.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/18.
//

import Foundation
import Combine
import web3
import BigInt


class WalletSync: ObservableObject {    
    @Published var chainToken: Token = .placeholder {
        didSet {
            print("CHANGED: WalletSync.chainToken: \(chainToken.amount)")
        }
    }
    
    @Published var tokens = [Token.placeholder] {
        didSet {
            print("CHANGED: WalletSync.tokens: \(tokens)")
        }
    }
    
    @Published var currentNetwork: Network {
        didSet {
            print("CHANGED: WalletSync.currentNetwork")
            prevBlockNumber = -1
            UserDefaults.standard.currentNetwork = currentNetwork
            client = EthereumClient(url: URL(string: currentNetwork.url)!)
            resetAndSync()
        }
    }
    
    var wallet: Wallet? {
        didSet {
            resetAndSync()
        }
    }
    
    private(set) var prevBlockNumber: Int = -1
    private(set) var curBlockNumber: Int = 0
    
    private var timer: AnyCancellable?
    private(set) var client: EthereumClient

    
    var networks: [Network] = {
        return Config.networks
    }()
    
    
    init() {
        currentNetwork = UserDefaults.standard.currentNetwork
        client = EthereumClient(url: URL(string: UserDefaults.standard.currentNetwork.url)!)
    }
    
    deinit {
        timer?.cancel()
    }
}


extension WalletSync {
    func resetAndSync() {
        // TODO: update to the token from the chain
        tokens = [.placeholder]
        chainToken = .placeholder
        Task {
            try? await self.sync(force: true)
        }
    }
    
    func startSync(wallet: Wallet) {
        self.wallet = wallet
        if timer == nil {
            Task {
                try? await sync(force: true)
            }
        }
        
        // TODO: what would happen if the timer event got fired while we are canceling
        // we would do sthing on the old address while we are working on the new one??
        timer?.cancel()
        // TODO: maybe not on: .main
        timer = Timer.publish(every: Config.walletSyncInterval, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .merge(with: Just(Date()))
            .sink() { counter in
                Task { [weak self] in
                    
                    // TODO: error handling
                    try await self?.sync()
                }
            }
    }
    
    func sync(force: Bool = false) async throws {
        guard let wallet = wallet else { return }
        
        if !force {
            guard try await hasNewBlock() == true else { return }
        }
        
        try await getBalance(ads: wallet.address)
        
        await MainActor.run {
            let sender = CombineNotificationSender("\(curBlockNumber)")
            NotificationCenter.default.post(name: CombineNotificationSender.newBlockNotification, object: sender)
        }
        
    }
    
    func getBalance(ads: String) async throws {
        let balance = try await client.eth_getBalance(address: EthereumAddress(ads), block: .Latest)
        
        // TOOD: is that necessary?
        await MainActor.run { [weak self] in
            guard let lSelf = self else { return }
            
            // TODO: assuming we only have eth in our token list..
            if chainToken.amount != balance {
                var tk = chainToken
                tk.amount = balance
                lSelf.chainToken = tk
                lSelf.tokens = [lSelf.chainToken]
            }
        }
    }
}


extension WalletSync {
    private func hasNewBlock() async throws -> Bool {
        let newBlockNum = try await client.eth_blockNumber()
        let prevBlockNum = curBlockNumber
        curBlockNumber = newBlockNum
        return newBlockNum > prevBlockNum
    }
}
