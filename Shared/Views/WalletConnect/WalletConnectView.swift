//
//  WalletConnectView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/28.
//

import SwiftUI
import CodeScanner
import WalletConnectSwift


struct WalletConnetCodeView: View {
    // Services
    @EnvironmentObject var walletConnect: WalletConnect
    @EnvironmentObject var walletProvider: WalletProvider
    
    // Sheet
    @State private var isPresentingScanner = false
    @State private var wcURL = ""
    
    
    
    var body: some View {
        Button {
            isPresentingScanner = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            Image(systemName: "camera.circle").resizable().frame(width: 44, height: 44)
        }
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr]) { response in
                switch response {
                  case .success(let result):
                    print(result.string)
                    guard result.string.starts(with: "wc:") else {
                        // TODO: NOT SUPPORTED
                        print("NOT SUPPPORTED!")
                        return
                    }
                    //                        try! WCClient.shared.client.pair(uri: result.string)
                    isPresentingScanner = false
                    wcURL = result.string
//                    showingWCDebug = true
                    guard let wcURL = WCURL(wcURL) else { return }
                    
                    // TODO: make sure to call this whenever we switch wallet?
                    walletConnect.configureServer()
                    
                    // TOOD: CACA
                    walletConnect.currentWallet = walletProvider.currentWallet
                    
                    // TODO: careful of reconnect logic in configureServer()
                    try! walletConnect.server.connect(to: wcURL)
                    // TODO: actually try to autoconnect at launch?
                    
                    
                   
                  case .failure(let error):
                    // TODO: failure?
                      print(error.localizedDescription)
                  }
            }
        }
    }
}
