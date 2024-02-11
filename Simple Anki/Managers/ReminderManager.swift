//
//  ReminderManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 03.05.2022.
//

import Foundation
import UserNotifications
import SwiftUI

struct Weekday: Identifiable, Codable {
    let id: Int
    let name: String
}

struct CustomNotification {
    let title: String
    let body: String
    let weekday: Weekday
}

class ReminderManager {
    static let shared = ReminderManager()
    let notificationCenter = UNUserNotificationCenter.current()

    let weekdays = [
        Weekday(id: 2, name: "Monday"),
        Weekday(id: 3, name: "Tuesday"),
        Weekday(id: 4, name: "Wednesday"),
        Weekday(id: 5, name: "Thursday"),
        Weekday(id: 6, name: "Friday"),
        Weekday(id: 7, name: "Saturday"),
        Weekday(id: 1, name: "Sunday")
    ]

    var notifications = [CustomNotification]()

    private init() { }

    func addAllDaysToReminder() {
        weekdays.forEach { day in
            UserDefaults.standard.set(day.id, forKey: day.name)
        }
    }

    func addWeekdayToReminder(index: Int) {
        UserDefaults.standard.set(weekdays[index].id, forKey: weekdays[index].name)
    }

    func addWeekdayToReminder(weekday: Weekday) {
        UserDefaults.standard.set(weekday.id, forKey: weekday.name)
    }

    func deleteDayFromReminder(index: Int) {
        UserDefaults.standard.set(0, forKey: weekdays[index].name)
    }

    func isDayInReminder(index: Int) -> Bool {
        return UserDefaults.standard.integer(forKey: weekdays[index].name) != 0
    }

    func isDayInReminder(weekday: Weekday) -> Bool {
        return UserDefaults.standard.integer(forKey: weekday.name) != 0
    }

    func collectSelectedWeekdays() -> [Weekday] {
        return weekdays.filter { isDayInReminder(weekday: $0) }
    }

    func setReminderOn() {
        UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.reminder)
    }

    func setReminderOff() {
        UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.reminder)
    }

    func isReminderOn() -> Bool {
        return UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.reminder)
    }

    func getReminderTime() -> Date? {
        guard let timeString = UserDefaults.standard.string(forKey: K.UserDefaultsKeys.reminderTime)
        else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.date(from: timeString)
    }

    func getNotificationsCredentials(weekdays: [Weekday]) -> [CustomNotification] {
        return weekdays.map {
            CustomNotification(title: "Review time!",
                               body: "Your decks are wating to be reviewed.",
                               weekday: $0)
        }
    }

    func scheduleNotifications(notifications: [CustomNotification]) {
        removeAllNotifications()
        guard let time = getReminderTime() else { return }
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            var dateComponents = DateComponents()
            dateComponents.timeZone = TimeZone.current
            dateComponents.hour = time.component(.hour)
            dateComponents.minute = time.component(.minute)
            dateComponents.weekday = notification.weekday.id
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: notification.weekday.name, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Uh oh! We had an error: \(error)")
                }
            }
        }
    }

    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
