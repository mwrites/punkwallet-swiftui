//
//  WalletStorage.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/28.
//

import Foundation
import web3
import KeychainAccess // https://github.com/kishikawakatsumi/KeychainAccess



public enum EthereumKeyStorageError: Error {
    case notFound
    case failedToSave
    case failedToLoad
}


class WalletStorage {
    //TODO: accessGroup??
//    let keychain = Keychain(service: "com.example.github-token", accessGroup: "12ABCD3E4F.shared")
    let keychain = Keychain(service: "com.punkwallet.privateKeys")
    
    init() {
        if Config.shouldPersistWallets {
            try? keychain.remove("privkeys")
        }
    }
    
    func importWallets(password: String) throws -> [Wallet] {
        var wallets = [Wallet]()
        let rawPkeys = try rawPrivKeysFromKeychain()
        
        for e in rawPkeys  {
            keychain[data: "lastUsedPrivateKey"] = e
            let decodedPkey = try KeystoreUtil.decode(data: e, password: password)
            let acc = try EthereumAccount.importAccount(keyStorage: self, privateKey: decodedPkey.web3.hexString, keystorePassword: Config.defaultKeyPassword, save: false)
            wallets.append(Wallet(account: acc))
        }
        return wallets
    }
}


extension WalletStorage: EthereumKeyStorageProtocol {
    // TODO: Refactor
    // keychain[data: "lastUsedPrivateKey"] is the ugly hack to simulate an iterator
    // Because EthereumAccount keep asking for the latest private key used in
    // In this setup we have ONE WalletStorage for MANY EthereumAccounts
    
    // Maybe find a way to do a 1 to 1 relationship and remove this hack
    
    func storePrivateKey(key: Data) throws -> Void {
        keychain[data: "lastUsedPrivateKey"] = key
        try savePrivateKeyToKeychain(key)
    }

    func loadPrivateKey() throws -> Data {
        guard let data = keychain[data: "lastUsedPrivateKey"] else {
             throw EthereumKeyStorageError.failedToLoad
        }
        return data
    }
}


extension WalletStorage {
    // WARNING: If you ever touch the serialization/deserialization
    // make sure to update the format version and think about migrations!
    
    private func rawPrivKeysFromKeychain() throws -> [Data] {
        var pkeys = [Data]()
        if let rawPkeys = keychain[data: "privkeys"] {
            pkeys = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawPkeys) as! [Data]
        }
        return pkeys
    }
    
    private func savePrivateKeyToKeychain(_ key: Data) throws {
        var pkeys = try rawPrivKeysFromKeychain()
        
        if pkeys.firstIndex(of: key) == nil {
            pkeys.append(key)
            
            keychain[data: "privkeys"] = try NSKeyedArchiver.archivedData(withRootObject: pkeys, requiringSecureCoding: true)
            keychain[string: "privkeys.format.version"] = Config.keychainSerializationFormatVersion
        }
    }
}
