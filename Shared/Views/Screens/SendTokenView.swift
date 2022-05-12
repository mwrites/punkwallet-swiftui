//
//  SendTokenView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import SwiftUI
import BigInt
import web3


class StringBoxReference {
    var value: String = ""
}

struct SendTokenView: View {
    @EnvironmentObject var errorPublisher: ErrorPublisher
    @EnvironmentObject var walletSync: WalletSync
    @EnvironmentObject var walletProvider: WalletProvider
    
    @StateObject private var contactProvider = ContactsProvider()
    
    @Binding var wallet: Wallet
    @Binding var tokens: [Token]
    
    @State var selectedToken: Token?
    @State private var enableInteraction: Bool = true
    
    var amountETH = StringBoxReference()
    
    
    var body: some View {
        Self._printChanges()
        return VStack(alignment: .center) {
            Text("Send Token")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
            
            SelectContactView(provider: contactProvider)
            Spacer()
            
            if contactProvider.isValidContact {
                if selectedToken == nil {
                    TokenListView(selectedToken: $selectedToken, tokens: $tokens)
                } else {
                    QuoteView(token: Binding($selectedToken)!, amountETH: amountETH)
                    // TODO: change state depending of if enough eth or not etc..
                    AsyncButton {
                        enableInteraction.toggle()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        await sendEth(destAds: contactProvider.destAddress, amountETH: amountETH.value)
                        enableInteraction.toggle()
                    } label: {
                        Image(systemName: "paperplane")
                    }
                    .padding()
                }                
            }
        }
        .padding()
        .disabled(!enableInteraction)
        .errorAlert(error: $errorPublisher.error)
        .onChange(of: tokens) {
            // TODO: hack to update selectedToken, should really either move the priceperToken out of token or used a selectedTokenName instead=
            selectedToken = tokens.first
            print("tokens: \($0)")
            
        }
        .onChange(of: selectedToken) {
            print("selectedToken: \($0)")
        }
    }
    
    
    func sendEth(destAds: EthereumAddress, amountETH: String) async {
        do {
            let wei = amountETH.wei
            print("Sending \(amountETH) to \(destAds)")
            let sendToken = SendToken(client: walletSync.client, account: walletProvider.currentWallet.account)
            try await sendToken.transferEth(destAds: destAds, amount: wei)
        } catch {
            print("Function: \(#function), line: \(#line), error: \(error)")
            errorPublisher.error = error
            //            showingAlert = true
        }
    }
}



struct TokenListView: View {
    @EnvironmentObject var uniswap: Uniswap
    @Binding var selectedToken: Token?
    @Binding var tokens: [Token]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                ForEach($tokens, id: \.self) { $tk in
                    BalanceCell(token: $tk) {
                        if let tkPrice = uniswap.pricesByToken[tk.name] {
                            selectedToken = Token(logo: tk.logo, name: tk.name, currency: tk.currency, amount: tk.amount, pricePerToken: tkPrice)
                        } else {
                            selectedToken = tk
                        }
                    }
                }
            }
        }
        .padding()
    }
}


