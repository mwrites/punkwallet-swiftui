////
////  WCClient.swift
////  punkwallet
////
////  Created by mwrites on 2022/4/17.
////
//
//import Foundation
//import WalletConnect
//import Relayer
//import web3 //move this
//import CryptoSwift
//
//class WCClientV2: WalletConnectClientDelegate {
//    
//    var walletManager: WalletManager!
//    
//    
//    var client: WalletConnectClient
//    var onSessionSettled: ((Session)->())?
//    var onSessionResponse: ((Response)->())?
//    var onSessionDelete: (()->())?
//    
//    static var shared: WCClient = WCClient()
//    private init() {
//        let metadata = AppMetadata(
//            name: "PunkWallet",
//            description: "PunkWallet!",
//            url: "https://punkwallet.io",
//            icons: ["https://walletconnect.org/walletconnect-logo.png"])
//        let relayer = Relayer(relayHost: "relay.walletconnect.com", projectId: Config.walletConnectID)
//        self.client = WalletConnectClient(metadata: metadata, relayer: relayer)
//        client.delegate = self
//    }
//    
//    func didSettle(session: Session) {
//        print("didSettle - session:\(session)")
//        onSessionSettled?(session)
//    }
//
//    func didDelete(sessionTopic: String, reason: Reason) {
//        print("sessionTopic - sessionTopic:\(sessionTopic), reason:\(reason)")
//        onSessionDelete?()
//    }
//
//    func didReceive(sessionResponse: Response) {
//        print("didReceive - sessionResponse:\(sessionResponse)")
//        onSessionResponse?(sessionResponse)
//    }
//    
//    func didUpdate(sessionTopic: String, accounts: Set<Account>) {
//        print("didUpdate - sessionTopic:\(sessionTopic), accounts:\(accounts)")
//    }
//    
//    func didUpgrade(sessionTopic: String, permissions: Session.Permissions) {
//        print("didUpgrade - sessionTopic:\(sessionTopic), permissions:\(permissions)")
//    }
//    
//    func didSettle(pairing: Pairing) {
//        print("didSettle - pairing:\(pairing)")
//    }
//    
//    func didReceive(notification: Session.Notification, sessionTopic: String) {
//        print("didReceive - notification:\(notification), sessionTopic:\(sessionTopic)")
//    }
//    
//    func didReject(pendingSessionTopic: String, reason: Reason) {
//        print("didReject - pendingSessionTopic:\(pendingSessionTopic), reason:\(reason)")
//    }
//    
//    func didUpdate(pairingTopic: String, appMetadata: AppMetadata) {
//        print("didUpdate - pairingTopic:\(pairingTopic), appMetadata:\(appMetadata)")
//    }
//    
//    func didReceive(sessionRequest: Request) {
//        print("didReceive - sessionRequest:\(sessionRequest)")
//    }
//    
////    lazy  var account = Signer.privateKey.address.hex(eip55: true)
//    
//    func didReceive(sessionProposal: Session.Proposal) {
//        print("didReceive - sessionProposal:\(sessionProposal)")
//        let appMetadata = sessionProposal.proposer
//        let info = SessionInfo(
//            name: appMetadata.name ?? "",
//            descriptionText: appMetadata.description ?? "",
//            dappURL: appMetadata.url ?? "",
//            iconURL: appMetadata.icons?.first ?? "",
//            chains: Array(sessionProposal.permissions.blockchains),
//            methods: Array(sessionProposal.permissions.methods), pendingRequests: [])
//        
//        print(info)
//        
//        
//        let keyStorage = EthereumKeyLocalStorage()
//        let pkeyData = try! keyStorage.loadPrivateKey()
//        let encryptedFile = try! JSONDecoder().decode(KeystoreFile.self, from: pkeyData)
//        
////        var hexPrivateKey = "0x7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d"
//        let hexPrivateKey = encryptedFile.address.value
//        
////        let account = hex(eip55: true)
//        
//        let accounts = Set(sessionProposal.permissions.blockchains.compactMap { Account($0+":\(hexPrivateKey)") })
//        client.approve(proposal: sessionProposal, accounts: accounts)
//    }
//    
//    
//}
//
//
//
//
//
//struct SessionInfo {
//    let name: String
//    let descriptionText: String
//    let dappURL: String
//    let iconURL: String
//    let chains: [String]
//    let methods: [String]
//    let pendingRequests: [String]
//}
//
//
//
//struct KeystoreFile: Codable {
//    let address: EthereumAddress
//}
//
