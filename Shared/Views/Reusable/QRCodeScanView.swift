//
//  QRCodeScanView.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/30.
//

import SwiftUI
import CodeScanner


struct QRCodeScanView: View {
    @State private var isPresentingScanner = false
    @State private var scannedUrl = ""
    
    var qrCodeParser: QRCodeParser
    
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            isPresentingScanner = true
        } label: {
            Image(systemName: "viewfinder")
                .resizable().frame(width: 44, height: 44)
                .foregroundColor(Theme.buttonActionColor)
        }
        .sheet(isPresented: $isPresentingScanner) {
            // TODO: consider fullscreen: https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-full-screen-modal-view-using-fullscreencover
            // TODO: doesn't work when scanning multiple times, should we just dismiss directly?
            
            CodeScannerView(codeTypes: [.qr]) { response in
                switch response {
                case .success(let result):
                    // TODO: if parse failure it seems we cannot let user scan another code
                    qrCodeParser.handle(text: result.string)
                case .failure(let error):
                    // TODO: if parse failure it seems we cannot let user scan another code
                    print(error.localizedDescription)
                }
                isPresentingScanner = false
            }
        }
    }
}


enum QRCodeType {
    case assumingEthereumAddress(String) // no protocol
    case ethereumAddress(String) // metamask format?
    case walletConnectRequest(String) // https://example.walletconnect.org/
    case unknown(String) // no handled
}


class QRCodeParser: ObservableObject {
    var onEthereumAddressDetected: ((String) -> Void)?
    var onWalletConnectDetected: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    @Published var ethereumAddress: String = ""
    
    func handle(text: String) {
        switch parse(text: text) {
        case let .ethereumAddress(url):
            print("ethreum address " + url)
            onEthereumAddressDetected?(url)
            ethereumAddress = url
        case let .assumingEthereumAddress(url):
            print("assuming Ethereum Address " + url)
            onEthereumAddressDetected?(url)
            ethereumAddress = url
        case let .walletConnectRequest(url):
            print("walletConnectRequestUrl " + url)
            onWalletConnectDetected?(url)
        case let .unknown(text):
            assertionFailure("Not handled!" + text)
        }
    }
    
    func parse(text: String) -> QRCodeType {
        let url = text.split(separator: ":", maxSplits: 1)
        
        if url.count == 1 {
            return QRCodeType.assumingEthereumAddress(String(url[0]))
        } else {
            switch url[0] {
            case let x where x.starts(with: "ethereum"):
                return QRCodeType.ethereumAddress(String(url[1]))
            case let x where x.starts(with: "wc"):
                return QRCodeType.walletConnectRequest(text)
            default:
                return QRCodeType.unknown(text)
            }
        }
    }
}
