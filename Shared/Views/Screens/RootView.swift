//
//  ContentView.swift
//  Shared
//
//  Created by mwrites on 2022/4/5.
//

import SwiftUI


enum Tab {
    case left
    case home
    case right
}


struct RootView: View {
    @EnvironmentObject var walletProvider: WalletProvider
    @EnvironmentObject var walletConnect: WalletConnect
    @EnvironmentObject var uniswap: Uniswap
    
    // Navigation
    @State private var currentTab = Tab.home
    @State private var showingSignaturePrompt = false

    
    var body: some View {
        Self._printChanges()
        return TabView(selection: $currentTab) {
            LeftView(currentTab: $currentTab.animation()).tag(Tab.left)
            HomeView().tag(Tab.home)
            RightView().tag(Tab.right)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
//        .indexViewStyle(.page(backgroundDisplayMode: .never))
        //TODO: not sure how to handle same session or new session also check Session: Equatable in WalletConnect.swift
//        .onChange(of: walletConnect.signInRequest?.session) { value in
//            showingSignaturePrompt = value != nil
//        }
        .sheet(isPresented: $showingSignaturePrompt) {
            SignaturePromptView()
        }
        .attachPartialSheetToRoot() // PartialSheet
        .task {
            // TODO: how often do we want to pull that? Also add retries
            try? await uniswap.getETHPrice()
        }
    }
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .previewDisplayName("iPhone 12")
        }
    }
}
