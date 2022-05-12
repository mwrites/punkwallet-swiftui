//
//  Wallet.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/14.
//

import SwiftUI
import web3
import CoreImage.CIFilterBuiltins


struct Wallet: Identifiable {
    let id = UUID()
    let account: EthereumAccount
    
    var balance = "..."
    var address: String { return account.address.value }
    
    // should really be a lazy var
    // but seems like mutating the struct is making SwiftUI infinite looping
    var qrCode: UIImage {
       let context = CIContext()
       let filter = CIFilter.qrCodeGenerator()
       filter.message = Data(address.utf8)

       if let outputImage = filter.outputImage {
           if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
               return UIImage(cgImage: cgimg)
           }
       }
       
       return UIImage(systemName: "xmark.circle") ?? UIImage()
   }
    
    mutating func setBalance(_ gwei: String) {
        balance = gwei
    }
}


extension Wallet: CustomStringConvertible {
    var description: String { return address }
}


extension Wallet: Equatable {
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.address == rhs.address
    }
}
