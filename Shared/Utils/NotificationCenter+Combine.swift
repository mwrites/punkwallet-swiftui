//
//  Combine.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/11.
//

import Combine
import Foundation

// Written by https://stackoverflow.com/questions/58559908/combine-going-from-notification-center-addobserver-with-selector-to-notificatio

class CombineNotificationSender {

    var message : String

    init(_ messageToSend: String) {
        message = messageToSend
    }

    static let newBlockNotification = Notification.Name(Config.stringWithAppID("notification.newBlock"))
    static let pendingTransactionNotification = Notification.Name(Config.stringWithAppID("notification.pendingTransaction"))
}

// TODO: make this generic
class WalletSyncListener {
    var cancelSet: Set<AnyCancellable> = []

    init(action: @escaping(Int)->Void) {
        NotificationCenter.default.publisher(for: CombineNotificationSender.newBlockNotification)
            .receive(on: RunLoop.main)
            .compactMap{$0.object as? CombineNotificationSender}
            .map{$0.message}
            .sink() {
                action(Int($0) ?? 0)
            }
            .store(in: &cancelSet)
    }
}

class PendingTransactionListener {
    var cancelSet: Set<AnyCancellable> = []

    init(action: @escaping(String)->Void) {
        NotificationCenter.default.publisher(for: CombineNotificationSender.pendingTransactionNotification)
            .receive(on: RunLoop.main)
            .compactMap{$0.object as? CombineNotificationSender}
            .map{$0.message}
            .sink() {
                action($0)
            }
            .store(in: &cancelSet)
    }
}

//let receiver = CombineNotificationReceiver()
//let sender = CombineNotificationSender("Message from sender")
//
//NotificationCenter.default.post(name: CombineNotificationSender.combineNotification, object: sender)
//sender.message = "Another message from sender"
//NotificationCenter.default.post(name: CombineNotificationSender.combineNotification, object: sender)



//import Combine
//import Foundation
//
//class CombineMessageSender {
//    @Published var message : String?
//}
//
//class CombineMessageReceiver {
//    private var cancelSet: Set<AnyCancellable> = []
//
//    init(_ publisher: AnyPublisher<String?, Never>) {
//        publisher
//            .compactMap{$0}
//            .sink() {
//                self.handleNotification($0)
//            }
//            .store(in: &cancelSet)
//    }
//
//    func handleNotification(_ message: String) {
//        print(message)
//    }
//}
//
//let sender = CombineMessageSender()
//let receiver = CombineMessageReceiver(sender.$message.eraseToAnyPublisher())
//sender.message = "Message from sender"
//sender.message = "Another message from sender"
