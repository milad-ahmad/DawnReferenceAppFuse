//
//  SwiftUIView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 11-05-2026.
//

import SwiftUI

#if canImport(UserNotifications)
import UserNotifications
#endif

@MainActor
class NotificationManager {

    static let instance = NotificationManager()

    func requestAuthorization() {
        Task {
            do {
                let options: UNAuthorizationOptions = [.alert, .badge, .sound]
                let success = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: options)

                if success {
                    print("Success")
                } else {
                    print("Permission denied")
                }
            } catch {
                print("Error: \(error)")
            }

        }
    }
    
    func scheduleNotification1() {
            Task {
                do {
                    let content = UNMutableNotificationContent()
                    content.title = "Test Notificatie"
                    content.body = "Dit is een body tekst."
                    
                    #if os(iOS)
                    content.subtitle = "Testing subtitle"
                    content.sound = .default
                    content.badge = 1
                    #endif
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
                    
                    let request = UNNotificationRequest(
                        identifier: "vaste_test_id",
                        content: content,
                        trigger: trigger)
                    
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
//    func scheduleNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "This is my first notification"
//        content.body = "Testing the body text"
//        content.subtitle = "Testing"
//        content.sound = .default
//        content.badge = 1
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4.0, repeats: false)
////        var dateComponents = DateComponents()
////        dateComponents.hour = 11
////        dateComponents.minute = 30
////        
////        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        
//        let request = UNNotificationRequest(
//            identifier: UUID().uuidString,
//            content: content,
//            trigger: trigger)
//        
//        Task {
//            do {
//                try await UNUserNotificationCenter.current().add(request)
//                print("SkipLog: Notification successfully added")
//            } catch {
//                print("Error scheduling notification")
//            }
//        }
//
//    }
}

struct NotificationView: View {
    var body: some View {
        VStack(spacing: 40) {
            Button("request permission") {
                NotificationManager.instance.requestAuthorization()
            }
            Button("Schedule notification") {
                NotificationManager.instance.scheduleNotification1()
            }
        }
        .onAppear {
            #if os(iOS)
            Task {
                try? await UNUserNotificationCenter.current().setBadgeCount(0)
            }
            #endif
        }
    }
}
