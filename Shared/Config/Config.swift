//
//  Config.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/17.
//

import Foundation


struct Config {
    // MARK: Config
    // Keys
    static let walletConnectID = "8ee4bff4451b2f219cc49f29fb3fcecd"
    
    
    // https://github.com/scaffold-eth/scaffold-eth/search?q=rinkeby
    // https://github.com/scaffold-eth/scaffold-eth/blob/7820476b3e4d030d1a3be0c31b4631d09066aec7/packages/hardhat/hardhat.config.js
    // https://chainlist.org/
    static var networks: [Network] = {
        return Bundle.main.decode([Network].self, from: "rpcConfig.json")
    }()
    
    // Keychain
    static let keychainSerializationFormatVersion = "1.0"
    
    // Sync
    static let walletSyncInterval: TimeInterval = 5
    
    // WalletConnectV1
    // TODO: PunkWalletTBC -> change to final one from Austin
    // TODO: Do we need to hide the production version from the build or github?
    static let walletConnectSessionKey = "walletconnect.session.key"
    
    // Uniswap
    static let uniswapSubgraphUrl = "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v2"
    // UniswapV2Pair Contract
    // https://etherscan.io/address/0xa478c2975ab1ea89e8196811f51a7b7ade33eb11#code
    static let uniswapPairContract = "0xa478c2975ab1ea89e8196811f51a7b7ade33eb11"
    
    
    static func stringWithAppID(_ string: String) -> String {
        return "com.punkwallet." + string
    }
    static let newWalletOnLaunchKey = Config.stringWithAppID("newWalletOnLaunch")

    // MARK: UX
    static var currentWalletKey = Config.stringWithAppID("wallet.current")
    static var defaultKeyPassword = "punkrocks"
    static let shouldPersistWallets = false
    static var signingConfirmationKey = Config.stringWithAppID("signing.confirm")
    
    // Contacts
    static let nMostUsedContacts = 5
}



extension UserDefaults {
    var currentNetwork: Network {
        get {
            if let rawNetwork = object(forKey: "network.current") as? Data {
                return try! JSONDecoder().decode(Network.self, from: rawNetwork)
            } else {
                return Config.networks.first { $0.chainId == 4 }!
            }
        } set {
            set(try! JSONEncoder().encode(newValue), forKey: "network.current")
        }
    }
    
    var shouldGenNewWalletOnLaunch: Bool {
        return UserDefaults.standard.bool(forKey: Config.stringWithAppID("launch.shouldGenNewWalletOnLaunch"))
    }
    
    var nRecentContacts: Int {
        get {
            let n = integer(forKey: "contacts.nRecentContacts")
            return n == 0 ? 5 : n
        } set {
            set(newValue, forKey: "contacts.nRecentContacts")
        }
    }
    
    var recentContacts: [Contact] {
        get {
            if let data = object(forKey: "contacts.recentContacts") as? Data {
                let objs = try? JSONDecoder().decode([Contact].self, from: data)
                return objs ?? []
            }
            return []
        } set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: "contacts.recentContacts")
        }
    }
}


extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
