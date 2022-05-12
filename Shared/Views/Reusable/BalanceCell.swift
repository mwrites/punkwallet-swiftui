//
//  BalanceCell.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/8.
//

import SwiftUI


struct BalanceCell: View {
    @Binding var token: Token
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(token.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)

            Button() {
                action?()
            } label: {
                VStack(alignment: .leading) {
                    Text(token.name)
                        .foregroundColor(Theme.primary)
                        .bold()
                    Text(token.tokenDisplay)
                        .foregroundColor(Theme.lightText)
                        .bold()
                }
            }
            Spacer()
        }
        .modifier(TappableZone())
    }
}
