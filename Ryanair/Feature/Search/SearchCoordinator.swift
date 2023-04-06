//
//  SearchCoordinator.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import UIKit

final class SearchCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    var parentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let controller = SearchViewController()
        controller.coordinator = self
        controller.viewModel = SearchViewModel(service: RyanairService())
        navigationController.pushViewController(controller, animated: true)
    }
    
    func goToSearchDetails(headerParams: [String: Any]) {
        let coordinator = SearchDetailsCoordinator(navigationController: navigationController, headerParams: headerParams)
        coordinator.parentCoordinator = self
        add(coordinator)
        coordinator.start()
    }
}
