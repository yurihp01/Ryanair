//
//  SearchViewModel.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import Foundation
import Combine

protocol SearchDetailsViewModelProtocol {
    func getFlight() -> AnyPublisher<[Flight], RyanairError>
    var headerParams: [String: Any] { get }
}

final class SearchDetailsViewModel {
    private var service: RyanairServiceProtocol
    private let subscriber = CurrentValueSubject<[Flight], RyanairError>([])
    private var cancellable = Set<AnyCancellable>()
    var headerParams: [String: Any]
    
    init(service: RyanairService, headerParams: [String: Any]) {
        self.service = service
        self.headerParams = headerParams
    }
}

extension SearchDetailsViewModel: SearchDetailsViewModelProtocol {
    func getFlight() -> AnyPublisher<[Flight], RyanairError> {
        return bindFlight()
    }
}

private extension SearchDetailsViewModel {
    func bindFlight() -> AnyPublisher<[Flight], RyanairError> {
        service.getFlight(params: &headerParams)
            .sink { [weak self] completion in
                self?.subscriber.send(completion: completion)
            } receiveValue: { [weak subscriber] flights in
                subscriber?.send(flights)
            }.store(in: &cancellable)
        return subscriber.eraseToAnyPublisher()
    }
}

