//
//  SearchCoordinator.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import UIKit

class SearchDetailsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    var parentCoordinator: Coordinator?
    
    var headerParams: [String: Any]
    
    init(navigationController: UINavigationController, headerParams: [String: Any]) {
        self.navigationController = navigationController
        self.headerParams = headerParams
    }
    
    func start() {
        let controller = SearchDetailsViewController()
        controller.coordinator = self
        controller.viewModel = SearchDetailsViewModel(service: RyanairService(), headerParams: headerParams)
        navigationController.pushViewController(controller, animated: true)
    }
}
