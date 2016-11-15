//
//  TaskViewController.swift
//  Procrastinate
//
//  Created by Aneta on 08.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class TaskViewController: UIViewController, MVVMViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel: TaskViewModel = {
        return TaskViewModel()
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }

    func bindViewModel() {
        self.viewModel.title.asObservable()
            .bindTo(self.rx.title)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel.data.asObservable()
            .bindTo(self.tableView.rx.items(dataSource: viewModel.dataSource))
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in self.tableView.deselectRow(at: indexPath, animated: true)})
            .addDisposableTo(self.disposeBag)
        
        self.viewModel.showLeftBarButton.asObservable()
            .filter { !$0 }
            .subscribe(onNext: { [unowned self] _ in self.navigationItem.leftBarButtonItem = nil })
            .addDisposableTo(self.disposeBag)
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: self.viewModel.cancel)
            .addDisposableTo(self.disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: self.viewModel.saveTask)
            .addDisposableTo(self.disposeBag)
    }
    
    @IBAction func onSaveBarButtonItemTouch(_ sender: AnyObject) {
        self.viewModel.saveTask()
    }
    
}

typealias TaskDetailsSection = SectionModel<String, SettingViewModel>
typealias TaskDetailsDataSource = RxTableViewSectionedReloadDataSource<TaskDetailsSection>

class TaskViewModel: ViewModel {
    
    let data = Variable([TaskDetailsSection]())
    
    let dataSource: TaskDetailsDataSource = {
        let dataSource = TaskDetailsDataSource()
        
        dataSource.configureCell = { (dataSouce, tableView, indexPath, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
            
            if let cell = cell as? SettingTableViewCell {
                cell.viewModel = viewModel
            }
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (dataSource, section) in
            return dataSource.sectionAtIndex(section).model
        }
        
        return dataSource
    }()
    
    let title = Variable("")
    let showLeftBarButton = Variable(true)
    
    var navigator: Navigator!
    
    var database = ProcrastinateDatabase.instance
    
    private let descriptionSetting: TextSettingViewModel
    private let deadlineSetting: DateSettingViewModel
    private let frequencySetting: PickerSettingViewModel
    private let repeatDaysSetting: NumberSettingViewModel
    
    convenience init() {
        self.init(description: "", deadline: Date(), frequency: .once, repeatDays: 0)
    }
    
    init(description: String, deadline: Date, frequency: TaskFrequency, repeatDays: Int) {
        self.descriptionSetting = TextSettingViewModel(title: "Description", text: description)
        self.deadlineSetting = DateSettingViewModel(title: "Deadline", date: deadline)
        self.frequencySetting = PickerSettingViewModel(title: "Frequency", frequency: frequency)
        self.repeatDaysSetting = NumberSettingViewModel(title: "Repeats interval", number: repeatDays)
        
        self.data.value = [
            TaskDetailsSection(model: "", items: [
                self.descriptionSetting,
                self.deadlineSetting,
                self.frequencySetting,
                self.repeatDaysSetting])
        ]
    }
    
    func getDescription() -> String {
        return self.descriptionSetting.textValue.value
    }
    
    func getDeadline() -> Date {
        return self.deadlineSetting.dateValue.value
    }
    
    func getFrequency() -> TaskFrequency {
        return self.frequencySetting.frequencyValue.value
    }
    
    func getRepeatDays() -> Int {
        return self.repeatDaysSetting.numberValue.value
    }
    
    func saveTask() {
        // no-op
    }
    
    func cancel() {
        // no-op
    }
    
}

class NewTaskViewModel: TaskViewModel {
    
    init() {
        super.init(description: "", deadline: Date(), frequency: .once, repeatDays: 0)
        
        self.title.value = "New task"
    }
    
    override func saveTask() {
        let newTask = Task(context: self.database.mainContext)
        newTask.taskDescription = getDescription()
        newTask.deadline = getDeadline()
        newTask.frequencyEnum = getFrequency()
        newTask.repeatsEvery = NSNumber(integerLiteral: getRepeatDays())
        
        self.database.saveContext()
        
        self.navigator.dismissViewController(animated: true)
    }
    
    override func cancel() {
        self.navigator.dismissViewController(animated: true)
    }
    
}

class EditTaskViewModel: TaskViewModel {
    
    let task: Task
    
    init(task: Task) {
        self.task = task
        
        super.init(description: task.taskDescription, deadline: task.deadline, frequency: task.frequencyEnum, repeatDays: task.repeatsEvery.intValue)
        
        self.title.value = "Edit task"
        self.showLeftBarButton.value = false
    }
    
    override func saveTask() {
        self.task.taskDescription = getDescription()
        self.task.deadline = getDeadline()
        self.task.frequencyEnum = getFrequency()
        self.task.repeatsEvery = NSNumber(integerLiteral: getRepeatDays())
        
        self.database.saveContext()
        
        self.navigator.popViewController(animated: true)
    }
    
    override func cancel() {
        self.navigator.popViewController(animated: true)
    }
    
}
