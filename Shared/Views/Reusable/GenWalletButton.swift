//
//  GenWalletButton.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/17.
//

import SwiftUI


struct GenWalletButton: View {
    var action: () -> Void


    var body: some View {
        Button("NEW WALLET") {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }
        .buttonStyle(GrowingButton())
    }
}
