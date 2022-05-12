//
//  punkwalletApp.swift
//  Shared
//
//  Created by mwrites on 2022/4/5.
//

import SwiftUI

@main
struct punkwalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var errorPublisher = ErrorPublisher.shared
    var walleySync = WalletSync()
    var walletProvider: WalletProvider!
    var transactions: Transactions
    var uniswap = Uniswap()
    // TODO: move this into walletSync or not?
//    private var walletConnect = WalletConnect()
    
    init() {
        _ = LocalNotifications.shared
        transactions = Transactions(client: walleySync.client)
        do {
            walletProvider = try WalletProvider()
        } catch {
            assertionFailure("Function: \(#function), line: \(#line), error: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light) // TODO: support dark mode
                .environmentObject(errorPublisher)
                .environmentObject(walletProvider)
                .environmentObject(walleySync)
                .environmentObject(transactions)
                .environmentObject(uniswap)
//                .environmentObject(walletConnect)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Here we actually handle the notification
        print("Notification received with identifier \(notification.request.identifier)")
        // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
}
