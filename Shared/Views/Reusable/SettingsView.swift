//
//  SettingsView.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/3.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(Config.signingConfirmationKey) private var signingConfirmation = true
    
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .padding()
        Divider()
        VStack(alignment: .leading) {
            Toggle("Ask for signing confirmations", isOn: $signingConfirmation)
            Spacer()
        }
        .padding()
    }
}
