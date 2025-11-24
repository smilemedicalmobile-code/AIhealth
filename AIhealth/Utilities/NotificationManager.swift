//
//  NotificationManager.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func showDownloadNotification(fileName: String) {
        scheduleNotification(
            title: "PDF 생성 완료",
            body: "\(fileName) 파일이 생성되었습니다."
        )
    }

    func showReservationNotification() {
        scheduleNotification(
            title: "예약 완료",
            body: "병원 예약이 성공적으로 접수되었습니다."
        )
    }
}
