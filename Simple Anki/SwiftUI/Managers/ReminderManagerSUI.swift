//
//  ReminderManagerSUI.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 08.02.2024.
//

import Foundation
import UserNotifications

@Observable
class ReminderViewModel {

    @ObservationIgnored
    private let weekdayKey: String = "weekdays"
    @ObservationIgnored
    private let timeKey: String = "selectedTime"
    @ObservationIgnored
    private let reminerStateKey: String = "reminderState"

    var selectedTime: Date = .now

    var isReminderOn: Bool = false

    var weekdays: [Weekday] = [] {
        didSet {
            saveSelectedWeekdays()
        }
    }

    private var notificationService: NotificationService

    init() {
        notificationService = NotificationService()
        fetchWeekdays()
        fetchTime()
        fetchReminderState()
    }

    func addWeekdayToReminder(weekday: Weekday) {
        weekdays.append(weekday)
    }

    func isWeekdayInReminder(weekday: Weekday) -> Bool {
        return weekdays.contains { $0.name == weekday.name }
    }

    func removeNotificationFromReminder(weekday: Weekday) {
        guard let index = findIndex(of: weekday) else { return }
        weekdays.remove(at: index)
        notificationService.removeNotification(id: weekday.name)

    }

    private func findIndex(of weekday: Weekday) -> Int? {
        return weekdays.firstIndex(where: { $0.name == weekday.name })
    }
}

extension ReminderViewModel {

    private func fetchWeekdays() {
        if let data = UserDefaults.standard.data(forKey: weekdayKey),
           let decoded = try? JSONDecoder().decode([Weekday].self, from: data) {
            weekdays = decoded
        }
    }

    func saveSelectedWeekdays() {
        if let encoded = try? JSONEncoder().encode(weekdays) {
            UserDefaults.standard.set(encoded, forKey: weekdayKey)
        }
    }

    func fetchTime() {
        if let time = UserDefaults.standard.object(forKey: timeKey) as? Date {
            selectedTime = time
        }
    }

    func saveSelectedTime() {
        UserDefaults.standard.setValue(selectedTime, forKey: timeKey)
    }

    func saveReminderState() {
        UserDefaults.standard.setValue(isReminderOn, forKey: reminerStateKey)
    }

    func turnOffNotifications() {
        notificationService.removeAllNotifications()
        weekdays = []
    }

    func fetchReminderState() {
        guard let reminderState = UserDefaults.standard.object(forKey: reminerStateKey) as? Bool else { return }
        isReminderOn = reminderState
    }

    func scheduleReminder(for weekday: Weekday) async {
        notificationService.removeNotification(id: weekday.name)
        let notifcation = notificationService.notificationsCredentials(weekday: weekday)
        let dateComponents = notificationService.buildDate(from: selectedTime, and: notifcation)
        do {
            let request = try notificationService.notificationRequest(for: dateComponents, notification: notifcation)
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Date {
    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
}

class NotificationService {

    enum NotificationError: Error {
        case error
    }

    private func notiicationContent(from notification: CustomNotification) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = notification.title
        content.body = notification.body
        return content
    }

    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

    }

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func notificationsCredentials(weekday: Weekday) -> CustomNotification {
        return CustomNotification(
                title: "Review time!",
                body: "Your decks are wating to be reviewed.",
                weekday: weekday
            )
    }

    func notificationRequest(for date: DateComponents, notification: CustomNotification) throws -> UNNotificationRequest {
        let content = notiicationContent(from: notification)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        return UNNotificationRequest(identifier: notification.weekday.name, content: content, trigger: trigger)
    }

    func buildDate(from date: Date, and notification: CustomNotification) -> DateComponents {
        return DateComponents(
            timeZone: TimeZone.current,
            hour: date.component(.hour),
            minute: date.component(.minute),
            weekday: notification.weekday.id
        )
    }
}
