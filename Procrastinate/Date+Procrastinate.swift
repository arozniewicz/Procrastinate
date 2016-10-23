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
    
    func adding(days: Int) -> Date {
        return self.addingTimeInterval(TimeInterval(days) * 24.0 * 60.0 * 60.0)
    }
    
}
