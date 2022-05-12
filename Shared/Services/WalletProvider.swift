//
//  WalletManager.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/18.
//

import SwiftUI
import web3


class WalletProvider: ObservableObject {
    @Published var wallets = [Wallet]()
    @Published var currentWallet: Wallet! {
        didSet {
            print("CHANGED: WalletProvider.currentWallet")
            UserDefaults.standard.set(currentWallet.address, forKey: Config.currentWalletKey)
        }
    }
    
    private let walletStorage = WalletStorage()
    
    
    init() throws {
        if UserDefaults.standard.shouldGenNewWalletOnLaunch {
            //TODO: testme
            try genWallet()
        }
        try loadWallets()
    }
}


extension WalletProvider {
    func loadWallets() throws  {
        wallets = try walletStorage.importWallets(password: Config.defaultKeyPassword)
        try loadCurrentWallet()
    }
    
    func loadCurrentWallet() throws {
        if let lastWalletAddress = UserDefaults.standard.string(forKey: Config.currentWalletKey) {
            let lastWallet = wallets.first {
                $0.address == lastWalletAddress
            }
            if let wallet = lastWallet {
                currentWallet = wallet
            }
        } else {
            try genWallet()
        }
    }
    
    func genWallet() throws  {
        
        // TODO: change this with biometrics
        let account = try EthereumAccount.create(keyStorage: walletStorage, keystorePassword: Config.defaultKeyPassword)
        
        let wallet =  Wallet(account: account)
        currentWallet = wallet
        
        wallets.append(wallet)
    }
}
