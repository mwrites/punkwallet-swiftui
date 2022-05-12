//
//  CurrentWalletView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/18.
//

import SwiftUI
import Combine


struct CurrentWalletView: View {
    @EnvironmentObject var qrCodeParser: QRCodeParser
    @EnvironmentObject var walletSync: WalletSync
    
    @Binding var wallet: Wallet
    
    @State var showSendEthView = false
    @State var ethereumAddress: String?
    
    var body: some View {
        print(Self._printChanges())
        return VStack {
            QRCodeView(qrCode: wallet.qrCode)
            
            Button(wallet.address) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                UIPasteboard.general.string = wallet.address
                print("Copied to pasteboard: ", wallet.address)
            }
            .font(.body)
            .lineLimit(1)
            .truncationMode(.middle)
            .buttonStyle(GrowingButton())
            
            BalanceCell(token: $walletSync.chainToken) { // TODO: handle chain native token separaretly and switch with network
                showSendEthView = true
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                showSendEthView = true
            } label: {
                Image(systemName: "paperplane")
                    .resizable().frame(width: 32, height: 32)
                    .foregroundColor(Theme.buttonActionColor)
            }
            .padding()
        }
        .sheet(isPresented: $showSendEthView) {
            SendTokenView(wallet: $wallet, tokens: $walletSync.tokens)
        }
        .onAppear(perform: syncWallet)
        .onChange(of: qrCodeParser.ethereumAddress) {
            guard !$0.isEmpty else { return }
            showSendEthView = true
        }
        .onChange(of: wallet) { _ in
            // TODO should use publishers?
            walletSync.wallet = wallet
        }
    }
    
    func syncWallet() {
        walletSync.startSync(wallet: wallet)
    }
}
