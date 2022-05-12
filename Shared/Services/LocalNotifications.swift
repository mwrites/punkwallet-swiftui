//
//  LocalNotifications.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/11.
//

import Foundation
import SwiftUI


class LocalNotifications {
    static let shared = LocalNotifications()
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func sendNotification(title: String, subtitle: String? = "", body: String, launchIn: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = body
        
        // TODO: logo
            let imageName = "punkwallet-logo"
            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
