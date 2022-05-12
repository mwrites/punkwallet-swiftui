//
//  WalletConnect.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import Foundation
import WalletConnectSwift
import web3


class WalletConnect: ObservableObject {
    var server: Server!
    private var baseHandler: BaseHandler!
    
    //TODO: where to put this?
    //TODO: actually how many sessions can we keep? what if I connect to multiple dapps
    @Published var session: Session?
    @Published var proposedSession: Session?
    @Published var signInRequest: SignInRequest?
    
    var currentWallet: Wallet!
    
    
    init() {
        server = Server(delegate: self)
        // TODO: UGLY SHIT
        server.register(handler: BaseHandler(server: server, walletConnect: self) { [weak self] in
            return self?.privateKey
        })
        server.register(handler: PersonalSignHandler(server: server, walletConnect: self) { [weak self] in
            return self?.privateKey
        })
        server.register(handler: SignTransactionHandler(server: server, walletConnect: self) { [weak self] in
            return self?.privateKey
        })
        
        // TODO: was useful for debug but retest this...
//        if let oldSessionObject = UserDefaults.standard.object(forKey: Config.walletConnectSessionKey) as? Data,
//           let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
//            try? server.reconnect(to: session)
//        }
    }
    
    //    func configureServer(for privateKey: String) {
    func configureServer() {
//        server.register(handler: BaseHandler(server: server, privateKey: privateKey))
        // TODO: reconnect logic-  maybe handle this somewher else
//        if let oldSessionObject = UserDefaults.standard.object(forKey: Config.walletConnectSessionKey) as? Data,
//           let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
//            try? server.reconnect(to: session)
//        }
    }
    
    // TODO: refactor
    var privateKey: String {
        let keyStorage = EthereumKeyLocalStorage()
        let pkeyData = try! keyStorage.loadPrivateKey()
        let encryptedFile = try! JSONDecoder().decode(KeystoreFile.self, from: pkeyData)
        return encryptedFile.address.value
    }
    
    // TODO: where should this come from?
    var chainId: Int {
        return 4
    }
}


extension WalletConnect: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        print("Function: \(#function), line: \(#line)")
    }
    
    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        print("Function: \(#function), line: \(#line)")
        
        // Publishes new session
        self.proposedSession = session
        
        let walletMeta = Session.ClientMeta(name: "Scaffold Wallet",
                                            description: "Scaffold Wallet",
                                            icons: [],
                                            url: URL(string: "https://buidlguidl.com")!)
        
        // Publishes new signInRequest
        signInRequest = SignInRequest(session: session) { [weak self] confirm in
            guard let lSelf = self else { return }
            
            let walletInfo  = Session.WalletInfo(approved: confirm,
                                                 accounts: [lSelf.privateKey],
                                                 chainId: lSelf.chainId, // TODO: how to get network? walletSync?
                                                 peerId: UUID().uuidString,
                                                 peerMeta: walletMeta)
            completion(walletInfo)
        }
        
        // Reset Proposal
//        self.proposedSession = nil
    }
    
    func server(_ server: Server, didConnect session: Session) {
        print("Function: \(#function), line: \(#line)")
        
        if let currentSession = self.session,
           currentSession.url.key != session.url.key {
            print("Test app only supports 1 session atm, cleaning...")
            try? self.server.disconnect(from: currentSession)
        }
        // TODO: sync session from another thread? publishing changes from background thread is not allowed!!
        
        self.session = session
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(sessionData, forKey: Config.walletConnectSessionKey)
        //        onMainThread {
        //            self.scanQRCodeButton.isHidden = true
        //            self.disconnectButton.isHidden = false
        //            self.statusLabel.text = "Connected to \(session.dAppInfo.peerMeta.name)"
        //        }
    }
    
    func server(_ server: Server, didDisconnect session: Session) {
        print("Function: \(#function), line: \(#line)")
        
        // TODO: how to do if never received this message but user disconnected from the dapp instead of the wallet?
        // THEN WE NEED TO CHECK AT THE RECONNECFT OR AT THE RELAUNCH?
        
        UserDefaults.standard.removeObject(forKey: Config.walletConnectSessionKey)
        //        onMainThread {
        //            self.scanQRCodeButton.isEnabled = true
        //            self.scanQRCodeButton.isHidden = false
        //            self.disconnectButton.isHidden = true
        //            self.statusLabel.text = "Disconnected"
        //        }
    }
    
    func server(_ server: Server, didUpdate session: Session) {
        print("Function: \(#function), line: \(#line)")
        
        // TODO: what to do?
    }
    
    
}

class BaseHandler: RequestHandler {
    let privateKeyProvider: () -> String?
    
    weak var server: Server?
    // TODO: HORRIBLE
    weak var walletConnect: WalletConnect?
    
    
    init(server: Server, walletConnect: WalletConnect, privateKeyProvider: @escaping () -> String?) {
        self.walletConnect = walletConnect
        self.server = server
        self.privateKeyProvider = privateKeyProvider
    }
    
    func canHandle(request: WalletConnectSwift.Request) -> Bool {
        print("Function: \(#function), line: \(#line), - '\(request.method)' is not supported!!!")
        return false
    }
    
    func handle(request: Request) {
        print("Function: \(#function), line: \(#line)")
        // to override
    }
    
    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
        print("Function: \(#function), line: \(#line)")
        guard let server = server else { return }
        
        let signature = sign()
        server.send(.signature(signature, for: request))
        
//        let onSign = {
//            let signature = sign()
//            server.send(.signature(signature, for: request))
//        }
//        let onCancel = {
//            server.send(.reject(request))
//        }
//        DispatchQueue.main.async {
//            print("Request to sign a message: \(message)")
            //            UIAlertController.showShouldSign(from: self.controller,
            //                                             title: "Request to sign a message",
            //                                             message: message,
            //                                             onSign: onSign,
            //                                             onCancel: onCancel)
//        }
    }
}


class PersonalSignHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "personal_sign"
    }

    override func handle(request: Request) {
        guard
            let server = self.server,
            let privateKey = self.privateKeyProvider()
        else { return }
        

        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: EthereumAddress.self, at: 1)

            guard address == EthereumAddress(privateKey) else {
                server.send(.reject(request))
                return
            }

            let decodedMessage = String(data: Data(hex: messageBytes), encoding: .utf8) ?? messageBytes

            askToSign(request: request, message: decodedMessage) { [weak self] in
                guard let wc = self?.walletConnect else { return "" }
                
                do {
                    return try wc.currentWallet.account.signMessage(message: Data(hex: messageBytes))
                } catch {
                    print(error)
                    return ""
                }
//                let (v, r, s) = try! self.privateKey.sign(message: .init(hex: personalMessageData.toHexString()))
//                return "0x" + r.toHexString() + s.toHexString() + String(v + 27, radix: 16) // v in [0, 1]
            }
        } catch {
            server.send(.invalid(request))
            return
        }
    }
}

class SignTransactionHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "eth_signTransaction"
    }

    override func handle(request: Request) {
        guard
            let server = self.server,
            let privateKey = self.privateKeyProvider()
        else { return }
        
        do {
            let wcTransact = try request.parameter(of: EthereumTransaction.self, at: 0)
            guard wcTransact.from == EthereumAddress(privateKey) else {
                server.send(.reject(request))
                return
            }
            
            
            askToSign(request: request, message: "JUST SIGN IT!") { [weak self] in
                do {
                    guard let wc = self?.walletConnect else { return "" }
                    
                    // TODO: note that we did this remap of transaction for
                    // - chainId
                    // - gasLimit -> gas
                    let transaction = EthereumTransaction(from: wcTransact.from, to: wcTransact.to, value: wcTransact.value, data: wcTransact.data, nonce: wcTransact.nonce, gasPrice: wcTransact.gasPrice, gasLimit: wcTransact.gas, chainId: wc.chainId)
                    
                    let signedTx = try wc.currentWallet.account.sign(transaction: transaction)
                    return signedTx.hash!.web3.hexString
                    
                    //                // also worked
                    //                let r = signedTx.r
                    //                let s = signedTx.s
                    //                let v = signedTx.v
                    //
                    //                return r.web3.hexString + s.web3.hexString.dropFirst(2) + v.web3.hexString.dropFirst(2)
                    //
                    //            askToSign(request: request, message: transaction.description) {
                    //                let signedTx = try! transaction.sign(with: self.privateKey, chainId: 4)
                    //                let (r, s, v) = (signedTx.r.web3, signedTx.s, signedTx.v)
                    //                return r.hex() + s.hex().dropFirst(2) + String(v.quantity, radix: 16)
                    //                }
                } catch {
                    print(error)
                    return ""
                }
            }

        } catch {
            server.send(.invalid(request))
        }
    }
}

extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }
}


// TODO: move me
struct KeystoreFile: Codable {
    let address: EthereumAddress
}


// MARK: - Publishing Events
struct SignInRequest: Equatable {
    let session: Session
    let confirm: (Bool) -> Void
    
    static func == (lhs: SignInRequest, rhs: SignInRequest) -> Bool {
        return lhs.session == rhs.session
    }
}

extension Session: Equatable {
    public static func == (lhs: Session, rhs: Session) -> Bool {
        // TODO: not sure about this
        return lhs.dAppInfo.peerId == rhs.dAppInfo.peerId && lhs.url.key == rhs.url.key
    }
}
