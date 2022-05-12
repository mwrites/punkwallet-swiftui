//
//  SelectContactView.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/8.
//

import SwiftUI


struct SelectContactView: View {
    @EnvironmentObject var qrCodeParser: QRCodeParser
    @ObservedObject var provider: ContactsProvider
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
        VStack {
            HStack {
                Text("To:")
                    .font(Font.headline.weight(.bold))
                    .foregroundColor(Color.gray)
                TextField("address or ens", text: $provider.destAddressTxt)
                    .modifier(ClearButton(text: $provider.destAddressTxt))
                    .keyboardType(.alphabet)
                    .focused($isFocused)
//                    .focused($focusedField, equals: .field)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .truncationMode(.middle)
                    .foregroundColor(Theme.highlighted)
                    .font(Font.headline.weight(.bold))
                Button("Paste") {
                    if let txt = UIPasteboard.general.string {
                        provider.destAddressTxt = txt
                    }
                }
                .font(Font.headline.weight(.bold))
            }
            Divider()
            if !provider.isValidContact {
                ContactListView(provider: provider)
                Spacer()
                HStack {
                    Spacer()
                        QRCodeScanView(qrCodeParser: qrCodeParser)
                        .padding(.trailing)
                }
            }
        }
        .onAppear {
            isFocused = true
            provider.consumeQRCodeParserAddress(qrCodeParser: qrCodeParser)
        }
        .onChange(of: qrCodeParser.ethereumAddress) { _ in
            provider.consumeQRCodeParserAddress(qrCodeParser: qrCodeParser)
        }
    }
}


struct ContactListView: View {
    @ObservedObject var provider: ContactsProvider
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Contacts")
                .font(Font.headline.weight(.bold))
                .foregroundColor(Color.gray)
            LazyVStack(alignment: .leading) {
                ForEach(provider.recentContacts) { e in
                    Button(e.ens ?? e.ads) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        provider.destAddressTxt = e.ens ?? e.ads
                    }
                    .font(Font.title3.bold())
                    .foregroundColor(Theme.buttonActionColor)
                    .minimumScaleFactor(0.01)
                    .padding(4)
                }
            }
        }
        .onAppear(perform: provider.getRecentContacts)
    }
}
