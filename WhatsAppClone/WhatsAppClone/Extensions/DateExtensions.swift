//
//  DateExtensions.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 21.01.2025.
//

import Foundation

extension Date {
    var dayOrTimeRepresentation: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: self)
            return formattedDate
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: self)
        }
    }
    
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: self)
        return formattedTime
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if isCurrentWeek {
            return toString(format: "EEEE")
        } else if isCurrentYear {
            return toString(format: "E, MMM d")
        } else {
            return toString(format: "MMM dd, yyyy")
        }
    }
    
    private var isCurrentWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    private var isCurrentYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}
