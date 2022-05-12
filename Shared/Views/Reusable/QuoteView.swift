//
//  QuoteView.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/10.
//

import SwiftUI
import Combine
import BigInt


struct QuoteView: View {
    @ObservedObject var quote: Quote
    
    var amountETH: StringBoxReference
    @Binding var token: Token
    
    @FocusState var focusedField: FocusField?
    
    
    init(token: Binding<Token>, amountETH: StringBoxReference) {
        _token = token
        self.amountETH = amountETH
        quote = Quote(pricePerToken: token.wrappedValue.pricePerToken)
    }
    
    
    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            BalanceCell(token: $token)
            
            AmountView(amount: $quote.amountETH, currency: token.currency, focusedField: _focusedField, focusFieldTag: .eth)
            AmountView(amount: $quote.amountUSD, currency: "USD", focusFieldTag: .usd)
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .eth
        }
        .onChange(of: quote.amountETH) {
            amountETH.value = $0
        }
    }
}


class Quote: ObservableObject {
    @Published var amountETH: String = ""
    @Published var amountUSD: String = ""
    
    @Published var isUserInteractingETH = false
    @Published var isUserInteractingUSD = false
    
    private var pricePerToken: Decimal
    
    
    init(pricePerToken: Decimal) {
        self.pricePerToken = pricePerToken
        
        // remove me this was to prevent the ping pong, but it's not enough
        isUserInteractingETH = true
        
        Publishers.CombineLatest($amountETH, $isUserInteractingETH)
            .debounce(for: 0.03, scheduler: RunLoop.main)
            .filter { $0.1 == true }
            .filter { Double($0.0) != nil }
            .map { (Decimal(string: $0.0) ?? 0).ethToUSD(price: pricePerToken) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .assign(to: &$amountUSD)
        
        // can't figure out how to remove the ping pong between both publishers,
        // ideally we should be able to differentiate between the input from the publisher and the input from the user
        // explored using custom textfield uiview representable, but failed to make the binding work.
        
//        Publishers.CombineLatest($amountUSD, $isUserInteractingUSD)
//            .debounce(for: 0.03, scheduler: RunLoop.main)
//            .filter { $0.1 == true }
//            .filter { Double($0.0) != nil }
//            .map { (Double($0.0) ?? 0).usdToEth(price: pricePerToken) }
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//            .assign(to: &$amountETH)
        
        
    }
}


enum FocusField: Hashable {
    case usd, eth
}


struct AmountView: View {
    @Binding var amount: String
    @State var currency: String
    
    @FocusState var focusedField: FocusField?
    @State var focusFieldTag: FocusField
    
    
    var body: some View {
        HStack {
            TextField("", text: $amount)
                .textFieldStyle(TextFieldAmountStyle())
                .focused($focusedField, equals: focusFieldTag)
            
            Spacer()
            
            // TODO: implement me
//            Button("Max") {
//                print("max")
//            }
//            .buttonStyle(SmallButtonStyle())
            
            Text(currency)
                .font(.title)
        }
        .frame(height: 30)
        .padding()
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
        .cornerRadius(45)
    }
}
