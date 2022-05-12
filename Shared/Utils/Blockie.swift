//
//  Blockies.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/19.
//

import Foundation

// TODO: check https://github.com/scaffold-eth/scaffold-eth/blob/punk-wallet/packages/react-app/src/components/QRPunkBlockie.jsx


// MARK: - Blockie
//extension Wallet {
//
//    private var currentPunkSpriteOrigin: CGPoint = .zero
//    @Published var currentPunk: UIImage = UIImage()
//
//    func generatePunk() {
//        let punksSprite = UIImage(named: "punks")!
//        let totalPunks = 10_000
//
//        // assuming png.width == png.height
//        // then...
//        // w and h = 2400*2400
//        // total of 10000 punks
//        // sqrt(10000) = 100 -> 100 per lines
//        // 2400 / 100 = 24 -> that's the size of the punk
//        let punkPerLines = sqrt(Double(totalPunks))
//        let punkLength = punksSprite.size.width / punkPerLines
//        let punkSize = CGSize(width: punkLength, height: punkLength)
//        let cgPunks = punksSprite.cgImage!.cropping(to: CGRect(origin: currentPunkSpriteOrigin, size: punkSize))
//        currentPunk = UIImage(cgImage: cgPunks!)
//
//        // incrementing next punk's origin
//        if (currentPunkSpriteOrigin.x + punkSize.width) / punkLength < punkPerLines {
//            currentPunkSpriteOrigin.x += punkSize.width
//        } else if (currentPunkSpriteOrigin.y + punkSize.height) / punkLength < punkPerLines {
//            print("switching line!", currentPunkSpriteOrigin)
//            currentPunkSpriteOrigin.x = 0
//            currentPunkSpriteOrigin.y += punkSize.height
//            print(wallets.count)
//        } else {
//            print("back to zero!", currentPunkSpriteOrigin)
//            currentPunkSpriteOrigin = .zero
//            print(wallets.count)
//        }
//    }
//}


