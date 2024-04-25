//
//  LocalNotifications.swift
//  LocalNotificationsFramework
//
//  Created by Rahul Kumar KALYAMPUDI on 23/04/24.
//

import Foundation
import UserNotifications

public class LocalNotifications {
    
    public init() {}
    
    public func scheduleLocalNotifications(forDates dates: [String], body: [String], title: [String], repeats: [Bool]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-HH:mm"
        let calendar = Calendar.current
        
        for (index, dateString) in dates.enumerated() {
            if let date = dateFormatter.date(from: dateString) {
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                
                if let year = components.year,
                   let month = components.month,
                   let day = components.day,
                   let hour = components.hour,
                   let minute = components.minute {
                    print("Year: \(year), Month: \(month), Day: \(day), Hour: \(hour), Minute: \(minute)")
                    
                    if #available(macOS 10.14, *) {
                        let trigger =  UNCalendarNotificationTrigger(dateMatching: DateComponents.triggerFor(date: day, month: month, hour: hour, minute: minute), repeats: repeats[index])
                        createNotificationContent(forTrigger: trigger, body: body[index], title: title[index])
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
            } else {
                print("Failed to parse date: \(dateString)")
            }
        }
    }
    
    public func scheduleLocalNotifications(forDays daysArray: [String], body: [String], title: [String], repeats: [Bool]) {
        for (index, dayString) in daysArray.enumerated() {
            let components = dayString.components(separatedBy: "-")
            
            if components.count >= 2 {
                let dayOfWeek = components[0]
                let time = components[1]
                
                if let day = DayOfWeek(stringValue: dayOfWeek) {
                    let timeArray = time.components(separatedBy: ":")
                    let hour = timeArray[0]
                    let seconds = timeArray[1]
                    if #available(macOS 10.14, *) {
                        let trigger =  UNCalendarNotificationTrigger(dateMatching: DateComponents.triggerFor(weekday: day.rawValue, hour: Int(hour) ?? 0, minute: Int(seconds) ?? 0), repeats: repeats[index])
                        createNotificationContent(forTrigger: trigger, body: body[index], title: title[index])
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    
                } else {
                    print("Invalid string value")
                }
            } else {
                print("Invalid string format: \(dayString)")
            }
        }
    }
    
    public func scheduleLocalNotifications(forSeconds secondsArray: [Int], body: [String], title: [String], repeats: [Bool]) {
        if #available(macOS 10.14, *) {
            var notificationTriggers: [UNNotificationTrigger] = []
            for (index,seconds) in secondsArray.enumerated() {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: repeats[index])
                notificationTriggers.append(trigger)
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    for (index, trigger) in notificationTriggers.enumerated() {
                        self.createNotificationContent(forTrigger: trigger, body: body[index], title: title[index])
                    }
                } else {
                    print("Permission denied for notifications.")
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(macOS 10.14, *)
    private func createNotificationContent(forTrigger notificationTrigger: UNNotificationTrigger, body: String? = nil, title: String? = nil) {
        let content = UNMutableNotificationContent()
        if let body = body, let title = title {
            content.title = title
            content.body = body
            content.sound = .default
        }
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: notificationTrigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
}

extension DateComponents {
    static func triggerFor(date: Int, month: Int, hour: Int, minute: Int) -> DateComponents {
        var component = DateComponents()
        component.day = date
        component.month = month
        component.hour = hour
        component.minute = minute
        return component
    }
    
    static func triggerFor(weekday: Int, hour: Int, minute: Int) -> DateComponents {
        var component = DateComponents()
        component.weekday = weekday
        component.hour = hour
        component.minute = minute
        return component
    }
}

public enum DayOfWeek: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    // Custom initializer to create enum from string
    init?(stringValue: String) {
        switch stringValue {
        case "SET_SUNDAY":
            self = .sunday
        case "SET_MONDAY":
            self = .monday
        case "SET_TUESDAY":
            self = .tuesday
        case "SET_WEDNESDAY":
            self = .wednesday
        case "SET_THURSDAY":
            self = .thursday
        case "SET_FRIDAY":
            self = .friday
        case "SET_SATURDAY":
            self = .saturday
        default:
            return nil
        }
    }
}
