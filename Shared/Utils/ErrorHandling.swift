//
//  ErrorHandling.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/9.
//

import SwiftUI
import web3


extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        return alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: {
            Text(error.wrappedValue?.localizedDescription ?? "")
        }
    }
}

class ErrorPublisher: ObservableObject {
    static let shared = ErrorPublisher()
    
    @Published var error: Error?
    
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name("web3.notification.ethereumRpcError"), object: nil, queue: .main) { [weak self] in
            guard
                let lSelf = self,
                let jsonRpcError = $0.object as? JSONRPCErrorDetail
            else { return }
            lSelf.error = NSError(domain: "com.web3.ethereumrpc.JSONRpcErrorDetail", code: jsonRpcError.code, userInfo: [NSLocalizedDescriptionKey:jsonRpcError.message])
        }
    }
    
    func setError(_ error: Error, blocking: Bool = false) {
        if blocking {
            self.error = error
        } else {
            LocalNotifications.shared.sendNotification(title: "Error", body: error.localizedDescription)
        }
    }
}
