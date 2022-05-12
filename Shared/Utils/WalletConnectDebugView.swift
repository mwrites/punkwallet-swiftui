//
//  WalletConnectDebugView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import SwiftUI
import WalletConnectSwift


struct WalletConnectDebugView: View {
    @EnvironmentObject var walletConnect: WalletConnect
    
    // Need to use Binding Instead of State: https://developer.apple.com/forums/thread/661777
    @Binding var wallet: Wallet
    @Binding var url: String
    
    
    var body: some View {
        VStack {
            Text("Wallet Address")
                .font(.largeTitle)
            Text(wallet.address)
            Text("Status")
                .font(.largeTitle)
            Text(walletConnect.session?.dAppInfo.peerMeta.name ?? "Disconnected")
        }
        .onAppear {
            guard let wcURL = WCURL(url) else { return }
            // TODO: careful of reconnect logic in configureServer()
            try! walletConnect.server.connect(to: wcURL)
        }
        
        .onDisappear {
            // TODO: when where how to disconnect
//            try! walletConnect.server.disconnect(from: walletConnect.session)
        }
    }
}
