//
//  WalletListViews.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/18.
//

import SwiftUI


struct WalletListView: View {
    @EnvironmentObject var walletProvider: WalletProvider
    
    // Navigation
    @Binding var currentTab: Tab
        
    
    var body: some View {
        VStack {
            Spacer()
            GenWalletButton(action: genWallet)
            Spacer()
            // ScrollView instead of List to hide the scrollbar indicator
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(walletProvider.wallets.reversed()) { wallet in
                        HStack {
                            //                                                Image(uiImage: wallet.punk)
                            //                                                    .interpolation(.none)
                            //                                                    .resizable()
                            //                                                    .scaledToFit()
                            //                                                    .frame(width: 40, height: 40)
                            //                                                    .background(.white)
                            let color = walletProvider.currentWallet == wallet ? Theme.selected : Theme.unselected
                            Button(wallet.address) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                walletProvider.currentWallet = wallet
                                currentTab = Tab.home
                            }
                            .foregroundColor(color)
                            .padding()
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func genWallet() {
        // TODO: handleme
        try! walletProvider.genWallet()
    }
}
