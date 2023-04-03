//
//  SearchViewModel.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import Foundation
import Combine

protocol SearchDetailsViewModelProtocol {
    func getFlights() -> AnyPublisher<[Flight], RyanairError>
}

class SearchDetailsViewModel {
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
    func getFlights() -> AnyPublisher<[Flight], RyanairError> {
        if let showfakeData = headerParams["showfakeData"] as? Bool, showfakeData == true,
           let flight = loadJson() {
            subscriber.send([flight])
            return subscriber.eraseToAnyPublisher()
        } else {
            return bindFlights()
        }
    }
}

private extension SearchDetailsViewModel {
    func bindFlights() -> AnyPublisher<[Flight], RyanairError> {
        service.getFlights()
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.subscriber.send(completion: .failure(error))
                case .finished:
                    print("Finished")
                }
            } receiveValue: { [weak self] flights in
                self?.subscriber.send(flights)
            }.store(in: &cancellable)
        return subscriber.eraseToAnyPublisher()
    }
    
    func loadJson() -> Flight? {
        if let url = Bundle.main.url(forResource: "searchFlight.json", withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Flight.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

