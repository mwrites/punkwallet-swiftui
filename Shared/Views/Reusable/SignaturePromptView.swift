//
//  SignatureRequest.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/20.
//

import SwiftUI
import WalletConnectSwift


// TODO: make this work without wallet connect?

struct SignaturePromptView: View {
    // Services
    @MainActor @EnvironmentObject var walletConnect: WalletConnect
    @EnvironmentObject var walletProvider: WalletProvider
    
    // Navigation
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            if let req = signInRequest {
                Text("Would you like to sign in with WalletConnect?")
                    .font(.largeTitle)
                Text(req.session.dAppInfo.peerMeta.url.absoluteString)
                    .font(.subheadline)
                Text(String(req.session.dAppInfo.chainId ?? 0)) // TODO: why chain is nil?
                    .font(.subheadline)
                Text(wallet.address)
                    .font(.subheadline)
                //debug
                    .onAppear {
                        walletConnect.signInRequest?.confirm(true)
                        dismiss()
                        // TODO: is there a way to achieve a popValue with combine?
                        walletConnect.signInRequest = nil
                    }
                
//                HStack {
//                    Button("Cancel") {
//                        walletConnect.signInRequest?.confirm(false)
//                        dismiss()
//                        // TODO: is there a way to achieve a popValue with combine?
//                        walletConnect.signInRequest = nil
//                    }
//                    Button("OK") {
//                        walletConnect.signInRequest?.confirm(true)
//                        dismiss()
//                        walletConnect.signInRequest = nil
//                    }
//                }
            }
        }
    }
    
    var signInRequest: SignInRequest? {
        // we need a copy of the request before it becomes nil
        return walletConnect.signInRequest
    }
    
    var wallet: Wallet {
        return walletProvider.currentWallet
    }
}
