//
//  LeftView.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/3.
//

import SwiftUI


struct LeftView: View {
    @EnvironmentObject var walletProvider: WalletProvider
    
    // Navigation
    @Binding var currentTab: Tab
    @State private var isSettingsPresented = false
       
   var body: some View {
       VStack {
           HStack {
               Spacer()
               Button {
                   UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                   isSettingsPresented = true
               } label: {
                   Image(systemName: "gearshape")
                       .resizable().frame(width: 32, height: 32)
                       .foregroundColor(Theme.buttonActionColor)
               }
               .padding()
           }
           WalletListView(currentTab: $currentTab)
       }
       .sheet(isPresented: $isSettingsPresented, content: SettingsView.init)
   }
}

