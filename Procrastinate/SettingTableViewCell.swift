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

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var viewModel: TextSettingViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            
            createBindings()
        }
    }
    
    var disposeBag = DisposeBag()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.valueTextField.becomeFirstResponder()
        }
    }
    
    private func createBindings() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.title.asObservable()
            .bindTo(self.titleLabel.rx.text)
            .addDisposableTo(self.disposeBag)
        
        (self.valueTextField.rx.textInput <-> viewModel.textValue).addDisposableTo(self.disposeBag)
    }
    
}

class NumberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var viewModel: NumberSettingViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            
            createBindings()
        }
    }
    
    var disposeBag = DisposeBag()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.valueTextField.becomeFirstResponder()
        }
    }
    
    private func createBindings() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.title.asObservable()
            .bindTo(self.titleLabel.rx.text)
            .addDisposableTo(self.disposeBag)
        
        (self.valueTextField.rx.textInput <-> viewModel.textValue).addDisposableTo(self.disposeBag)
    }
    
}

class DateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var viewModel: DateSettingViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            
            createBindings()
        }
    }
    
    var disposeBag = DisposeBag()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        return datePicker
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.valueTextField.inputView = self.datePicker
        self.valueTextField.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.valueTextField.becomeFirstResponder()
        }
    }
    
    private func createBindings() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.title.asObservable()
            .bindTo(self.titleLabel.rx.text)
            .addDisposableTo(self.disposeBag)
        
        viewModel.textValue.asObservable()
            .map { $0 as String? }
            .bindTo(self.valueLabel.rx.text)
            .addDisposableTo(self.disposeBag)
        
        (self.datePicker.rx.date <-> viewModel.dateValue).addDisposableTo(self.disposeBag)
    }
    
}

protocol SettingViewModel {
        
    func dequeueCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell
    
}

class TextSettingViewModel: SettingViewModel {
    
    let title: Variable<String?>
    let textValue: Variable<String>
    
    init(title: String, text: String) {
        self.title = Variable(title)
        self.textValue = Variable(text)
    }
    
    func dequeueCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        
        if let cell = cell as? TextTableViewCell {
            cell.viewModel = self
        }
        
        return cell
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
    
    override func dequeueCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath)
        
        if let cell = cell as? NumberTableViewCell {
            cell.viewModel = self
        }
        
        return cell
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
    
    override func dequeueCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath)
        
        if let cell = cell as? DateTableViewCell {
            cell.viewModel = self
        }
        
        return cell
    }
    
}
