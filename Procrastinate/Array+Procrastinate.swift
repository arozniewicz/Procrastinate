//
//  Array+Procrastinate.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func remove(element: Element) -> Element? {
        if let index = self.index(of: element) {
            return self.remove(at: index)
        }
        return nil
    }
    
}

extension Array where Element: Hashable {
    
    func unique() -> [Element] {
        let set = Set(self)
        
        return [Element](set)
    }
    
}
