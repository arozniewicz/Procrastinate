//
//  TasksViewController.swift
//  Procrastinate
//
//  Created by Aneta on 08.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import CoreData

class TasksViewController: UIViewController, UITableViewDelegate, MVVMViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel: TasksViewModel = {
        return TasksViewModel(navigator: ViewControllerNavigator(viewController: self))
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "task")
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationWillEnterForeground)
            .map { _ in () }
            .bindNext(self.viewModel.fetchTasks)
            .addDisposableTo(self.disposeBag)
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.fetchTasks()
    }
    
    func bindViewModel() {
        self.viewModel.data.asObservable()
            .bindTo(self.tableView.rx.items(dataSource: self.viewModel.dataSource))
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.modelSelected(TaskCellViewModel.self)
            .bindNext(self.viewModel.complete)
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.modelAccessoryButtonTapped(TaskCellViewModel.self)
            .bindNext(self.viewModel.showTaskDetails)
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.modelDeleted(TaskCellViewModel.self)
            .bindNext(self.viewModel.delete)
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in self.tableView.deselectRow(at: indexPath, animated: true) })
            .addDisposableTo(self.disposeBag)
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .bindNext(self.viewModel.undo)
            .addDisposableTo(self.disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bindNext(self.viewModel.showNewTask)
            .addDisposableTo(self.disposeBag)
    }
    
}

typealias TasksSection = AnimatableSectionModel<String, TaskCellViewModel>
typealias TasksDataSource = RxTableViewSectionedAnimatedDataSource<TasksSection>

class TasksViewModel: ViewModel {
    
    let data = Variable([TasksSection]())
    
    let dataSource: TasksDataSource = {
        let dataSource = TasksDataSource()
        
        dataSource.configureCell = { (dataSource, tableView, indexPath, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
            
            (cell as? TaskTableViewCell)?.viewModel = viewModel
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (dataSource, section) in
            return dataSource.sectionAtIndex(section).model
        }
        
        dataSource.canEditRowAtIndexPath = { _ in return true }
        
        return dataSource
    }()
    
    var navigator: Navigator!
    
    var database = ProcrastinateDatabase.instance
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private var tasks = [Task]()
    
    init(navigator: Navigator) {
        self.navigator = navigator
    }
    
    func fetchTasks() {
        let tasks = self.database.fetch(type: Task.self)
        
        self.tasks = validateTasks(tasks: tasks)
        
        updateData()
    }
    
    private func validateTasks(tasks: [Task]) -> [Task] {
        let today = Date().noon
        
        for task in tasks {
            if task.deadline.noon.compare(today) == .orderedAscending {
                task.deadline = today
            }
        }
        
        self.database.saveContext()
        
        return tasks
    }
    
    private func updateData() {
        let dates = self.tasks.map { $0.deadline.noon }.unique().sorted()
        
        self.data.value = dates.map { date in
            TasksSection(
                model: self.dateFormatter.string(from: date),
                items: self.tasks.filter { $0.deadline.noon == date }.map { TaskCellViewModel(task: $0) })
        }
    }
    
    func showNewTask() {
        self.navigator.presentViewController(type: TaskViewController.self, viewModel: NewTaskViewModel(), animated: true)
    }
    
    func showTaskDetails(taskViewModel: TaskCellViewModel) {
        self.navigator.pushViewController(type: TaskViewController.self, viewModel: EditTaskViewModel(task: taskViewModel.task), animated: true)
    }
    
    func complete(taskViewModel: TaskCellViewModel) {
        let task = taskViewModel.task
        
        guard task.frequencyEnum != .once else {
            delete(taskViewModel: taskViewModel)
            
            return
        }
        
        task.complete()
        
        self.database.saveContext()
        
        updateData()
    }
    
    func delete(taskViewModel: TaskCellViewModel) {
        let task = taskViewModel.task
        
        self.database.delete(object: task)
        self.database.saveContext()
        
        let _ = self.tasks.remove(element: task)
        
        updateData()
    }
    
    func undo() {
        self.database.undo()
        self.database.saveContext()
        
        fetchTasks()
    }
    
}
