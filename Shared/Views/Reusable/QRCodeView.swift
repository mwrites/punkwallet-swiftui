//
//  QRCodeView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import SwiftUI


struct QRCodeView: View {
    @State var qrCode: UIImage
    
    var body: some View {
        ZStack {
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
    //                Image(uiImage: walletProvider.currentPunk)
    //                    .interpolation(.none)
    //                    .resizable()
    //                    .scaledToFit()
    //                    .frame(width: 80, height: 80)
    //                    .background(.white)
        }
    }
}
