//
//  SearchViewModel.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import Foundation
import Combine

protocol SearchViewModelProtocol {
    func bindStations() -> AnyPublisher<[Station], RyanairError>
}

class SearchViewModel {
    private var service: RyanairServiceProtocol
    private var cancellable = Set<AnyCancellable>()
    
    init(service: RyanairService) {
        self.service = service
    }
}

extension SearchViewModel: SearchViewModelProtocol {
    func bindStations() -> AnyPublisher<[Station], RyanairError> {
        let stationSubscriber = PassthroughSubject<[Station], RyanairError>()
        service.getStations()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    stationSubscriber.send(completion: .failure(error))
                case .finished: break
                }
            }, receiveValue: { stations in
                stationSubscriber.send(stations)
            }).store(in: &cancellable)
        return stationSubscriber.eraseToAnyPublisher()
    }
}

