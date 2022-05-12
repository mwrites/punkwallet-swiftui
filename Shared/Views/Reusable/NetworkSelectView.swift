//
//  NetworkSelectView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/28.
//

import SwiftUI
import PartialSheet


// TOOD: Seems there is a bug when the view is refreshing the popup doesn't play well
// https://github.com/AndreaMiotto/PartialSheet
struct NetworkSelectView: View {
    @EnvironmentObject var walletSync: WalletSync
    
    @State private var isSheetPresented = false
    
    
    var body: some View {
        PSButton(
            isPresenting: $isSheetPresented,
            label: {
                Text(walletSync.currentNetwork.name)
            })
            .padding()
        .buttonStyle(GrowingButton())
        // TODO: Styling https://github.com/AndreaMiotto/PartialSheet/wiki/3.-Custom-Style#custom-style
        .partialSheet(isPresented: $isSheetPresented, content: {
            NetworkListView(isPresented: $isSheetPresented)
        })
//        .partialSheet(isPresented: $$isSheetPresented) {
//
//        }
    }
}


struct NetworkListView: View {
    @EnvironmentObject var walletSync: WalletSync
    @Binding var isPresented: Bool
    
    var body: some View {
        LazyVStack {
            ForEach(networks, id: \.self) { e in
                Button(e.name) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    walletSync.currentNetwork = e
                    isPresented = false
                }
                .font(Font.title3.weight(.bold))
                .foregroundColor(Theme.buttonActionColor)
                .lineLimit(1)
                .padding(4)
                Spacer()
            }
        }.onAppear {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
            
    var networks: [Network] {
        return walletSync.networks
    }
}
//
//struct PartialSheetExampleView: View {
//    @State private var longer: Bool = false
//    @State private var text: String = "some text"
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Group {
//                HStack {
//                    Spacer()
//                Text("Settings Panel")
//                    .font(.headline)
//                    Spacer()
//                }
//
//                Text("Vestibulum iaculis sagittis sem, vel hendrerit ex. ")
//                    .font(.body)
//                    .lineLimit(2)
//
//                Toggle(isOn: self.$longer) {
//                    Text("Advanced")
//                }
//            }
//            .padding(0)
//            .frame(height: 50)
//            if self.longer {
//                VStack {
//                    Divider()
//                    Spacer()
//                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vestibulum porttitor ligula quis faucibus. Maecenas auctor tincidunt maximus. Donec lectus dui, fermentum sed orci gravida, porttitor porta dui. ")
//                    Spacer()
//                }
//                .frame(height: 200)
//            }
//        }
//        .padding(.horizontal, 10)
//    }
//}
