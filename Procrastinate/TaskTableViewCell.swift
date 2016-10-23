//
//  TaskTableViewCell.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxDataSources

class TaskTableViewCell: UITableViewCell {
    
    var viewModel: TaskCellViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            
            bindViewModel()
        }
    }
    
    var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .detailButton
    }
    
    func bindViewModel() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.taskDescription.asObservable()
            .bindTo(self.textLabel!.rx.text)
            .addDisposableTo(self.disposeBag)
        
        viewModel.taskRepeats.asObservable()
            .bindTo(self.detailTextLabel!.rx.text)
            .addDisposableTo(self.disposeBag)
    }
    
}

class TaskCellViewModel: IdentifiableType, Equatable {
    
    let taskDescription: Variable<String?>
    let taskRepeats: Variable<String?>
        
    var task: Task
    
    var identity: NSManagedObjectID {
        return self.task.objectID
    }
    
    init(task: Task) {
        self.task = task
        
        self.taskDescription = Variable(task.taskDescription)
        self.taskRepeats = Variable(task.repeatsString)
    }
    
    static func ==(lhs: TaskCellViewModel, rhs: TaskCellViewModel) -> Bool {
        return lhs.taskDescription.value == rhs.taskDescription.value && lhs.taskRepeats.value == rhs.taskRepeats.value
    }
    
}

private extension Task {
    
    var repeatsString: String {
        switch self.repeats {
        case 0: return "Once"
        case 1: return "Repeats every day"
        default: return "Repeats every \(self.repeats) days"
        }
    }
    
}
