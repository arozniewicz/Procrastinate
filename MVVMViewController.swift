//
//  MVVMViewController.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import Foundation

protocol MVVMViewController: class {
    
    associatedtype ViewModelType: ViewModel
    
    var viewModel: ViewModelType { get set }
    
}
