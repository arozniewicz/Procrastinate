//
//  SettingTableViewCell.swift
//  Procrastinate
//
//  Created by Aneta on 09.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var viewModel: SettingViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            
            self.viewModel?.configureCell(cell: self)
            self.viewModel?.bindViewModelToCell(cell: self)
        }
    }
    
    var disposeBag = DisposeBag()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        return datePicker
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.valueTextField.becomeFirstResponder()
        }
    }
    
}

protocol SettingViewModel {
    
    func bindViewModelToCell(cell: SettingTableViewCell)
    func configureCell(cell: SettingTableViewCell)
    
}

class TextSettingViewModel: NSObject, SettingViewModel {
    
    let title: Variable<String?>
    let textValue: Variable<String>
    
    init(title: String, text: String) {
        self.title = Variable(title)
        self.textValue = Variable(text)
    }
    
    func bindViewModelToCell(cell: SettingTableViewCell) {
        self.title.asObservable()
            .bindTo(cell.titleLabel.rx.text)
            .addDisposableTo(cell.disposeBag)
        
        (cell.valueTextField.rx.textInput <-> self.textValue).addDisposableTo(cell.disposeBag)
    }
    
    func configureCell(cell: SettingTableViewCell) {
        cell.valueLabel.isHidden = true
    }
    
}

class NumberSettingViewModel: TextSettingViewModel {
    
    let numberValue: Variable<Int>
    
    private let disposeBag = DisposeBag()
    
    init(title: String, number: Int) {
        self.numberValue = Variable(number)
        
        super.init(title: title, text: "")
        
        let numberToText = self.numberValue.asObservable()
            .map { number in "\(number)" }
            .bindTo(self.textValue)
        
        let textToNumber = self.textValue.asObservable()
            .subscribe(onNext: { text in
                let number = Int(text) ?? 0
                
                if self.numberValue.value != number {
                    self.numberValue.value = number
                }
            })
        
        Disposables.create(textToNumber, numberToText).addDisposableTo(self.disposeBag)
    }
    
    override func configureCell(cell: SettingTableViewCell) {
        cell.valueLabel.isHidden = true
        cell.valueTextField.keyboardType = .numberPad
    }
    
}

class DateSettingViewModel: TextSettingViewModel {
    
    let dateValue: Variable<Date>
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private let disposeBag = DisposeBag()
    
    
    init(title: String, date: Date) {
        self.dateValue = Variable(date)
        
        super.init(title: title, text: "")
        
        self.dateValue.asObservable()
            .map { [unowned self] in self.dateFormatter.string(from: $0) }
            .bindTo(self.textValue)
            .addDisposableTo(self.disposeBag)
    }
    
    override func bindViewModelToCell(cell: SettingTableViewCell) {
        self.title.asObservable()
            .bindTo(cell.titleLabel.rx.text)
            .addDisposableTo(cell.disposeBag)
        
        self.textValue.asObservable()
            .map { $0 as String? }
            .bindTo(cell.valueLabel.rx.text)
            .addDisposableTo(cell.disposeBag)
        
        (cell.datePicker.rx.date <-> self.dateValue).addDisposableTo(cell.disposeBag)
    }
    
    override func configureCell(cell: SettingTableViewCell) {
        cell.valueTextField.inputView = cell.datePicker
        cell.valueTextField.isHidden = true
    }
    
}

class PickerSettingViewModel: TextSettingViewModel, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let frequencyValue: Variable<TaskFrequency>
    
    let values: [TaskFrequency] = [.once, .daily, .weekly, .monthly, .yearly]
    
    private let disposeBag = DisposeBag()
    
    init(title: String, frequency: TaskFrequency) {
        self.frequencyValue = Variable(frequency)
        
        super.init(title: title, text: "")
        
        self.frequencyValue.asObservable()
            .map { $0.stringValue }
            .bindTo(self.textValue)
            .addDisposableTo(self.disposeBag)
    }
    
    override func bindViewModelToCell(cell: SettingTableViewCell) {
        cell.pickerView.dataSource = self
        cell.pickerView.delegate = self
        
        cell.pickerView.selectRow(self.values.index(of: self.frequencyValue.value) ?? 0, inComponent: 0, animated: false)
        
        self.title.asObservable()
            .bindTo(cell.titleLabel.rx.text)
            .addDisposableTo(cell.disposeBag)
        
        self.textValue.asObservable()
            .map { $0 as String? }
            .bindTo(cell.valueLabel.rx.text)
            .addDisposableTo(cell.disposeBag)
        
        cell.pickerView.rx.itemSelected
            .subscribe(onNext: self.pickValue)
            .addDisposableTo(cell.disposeBag)
    }
    
    override func configureCell(cell: SettingTableViewCell) {
        cell.valueTextField.inputView = cell.pickerView
        cell.valueTextField.isHidden = true
    }
    
    func pickValue(row: Int, _: Int) {
        self.frequencyValue.value = self.values[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.values[row].stringValue
    }
    
}

private extension TaskFrequency {
    
    var stringValue: String {
        switch self {
        case .once: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    static func fromString(string: String) -> TaskFrequency {
        switch string {
        case "Once": return TaskFrequency.once
        case "Daily": return TaskFrequency.daily
        case "Weekly": return TaskFrequency.weekly
        case "Monthly": return TaskFrequency.monthly
        case "Yearly": return TaskFrequency.yearly
        default: return .once
        }
    }
    
}
