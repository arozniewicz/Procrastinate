//
//  UITableView+Rx+Model.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    
    func modelAccessoryButtonTapped<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemAccessoryButtonTapped.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    func modelDeleted<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemDeleted.flatMap { [weak view = self.base as UITableView] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
}
