//
//  HomeView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var walletProvider: WalletProvider
    @StateObject var qrCodeParser: QRCodeParser =  QRCodeParser()
    @State private var showSendEthView: Bool = false
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                QRCodeScanView(qrCodeParser: qrCodeParser)
                    .padding(.trailing)
            }
            HStack {
                Spacer()
                NetworkSelectView()
                Spacer()
            }
            CurrentWalletView(wallet: $walletProvider.currentWallet)
            Spacer()
        }
        .padding()
        .environmentObject(qrCodeParser)
    }
}
