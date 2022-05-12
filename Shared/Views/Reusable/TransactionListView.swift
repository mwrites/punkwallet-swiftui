//
//  TransactionListView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/18.
//

import SwiftUI


struct TransactionListView: View {
    @EnvironmentObject var transactions: Transactions
    
    var body: some View {
        VStack {
            Text("Transactions")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(transactions.transactions.keys.reversed(), id: \.self) { k in
                        HStack {
                            Text(k)
                                .font(.body)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Divider()
                            Text(String(transactions.transactions[k]!.stringValue))
                                .font(.body)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
