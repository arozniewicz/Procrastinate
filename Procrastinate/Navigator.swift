//
//  Navigator.swift
//  Procrastinate
//
//  Created by Aneta on 22.10.2016.
//  Copyright © 2016 Aneta Różniewicz. All rights reserved.
//

import UIKit

protocol Navigator {
    
    func pushViewController<T>(type: T.Type, viewModel: T.ViewModelType, animated: Bool) where T: MVVMViewController
    
    func popViewController(animated: Bool)
    
    func presentViewController<T>(type: T.Type, viewModel: T.ViewModelType, animated: Bool) where T: MVVMViewController

    func dismissViewController(animated: Bool)

}

class ViewControllerNavigator: Navigator {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func pushViewController<T>(type: T.Type, viewModel: T.ViewModelType, animated: Bool) where T: MVVMViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type))
        let newViewController = storyboard.instantiateViewController(withIdentifier: String(describing: type))
        
        var viewModel = viewModel
        viewModel.navigator = ViewControllerNavigator(viewController: newViewController)
        
        (newViewController as? T)?.viewModel = viewModel

        self.viewController?.navigationController?.pushViewController(newViewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        let _ = self.viewController?.navigationController?.popViewController(animated: animated)
    }
    
    func presentViewController<T>(type: T.Type, viewModel: T.ViewModelType, animated: Bool) where T: MVVMViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type))
        let newViewController = storyboard.instantiateViewController(withIdentifier: String(describing: type))

        let navigationController = UINavigationController(rootViewController: newViewController)
        
        var viewModel = viewModel
        viewModel.navigator = ViewControllerNavigator(viewController: newViewController)
        
        (newViewController as? T)?.viewModel = viewModel
        
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func dismissViewController(animated: Bool) {
        self.viewController?.dismiss(animated: animated, completion: nil)
    }

}
