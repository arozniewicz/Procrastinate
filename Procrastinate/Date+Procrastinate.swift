//
//  Date+Procrastinate.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation

extension Date {
    
    var noon: Date {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents(Set(arrayLiteral: .year, .month, .day), from: self)
        
        return calendar.date(from: dateComponents) ?? self
    }
    
    func adding(days: Int = 0, weeks: Int = 0, months: Int = 0, years: Int = 0) -> Date {
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.day = days
        dateComponents.weekOfYear = weeks
        dateComponents.month = months
        dateComponents.year = years
        
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
    
}
