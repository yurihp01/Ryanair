//
//  SearchViewModel.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 01/04/2023.
//

import Foundation
import Combine

protocol SearchDetailsViewModelProtocol {
    func getFlight() -> AnyPublisher<Flight, RyanairError>
    var headerParams: [String: Any] { get }
}

class SearchDetailsViewModel {
    private var service: RyanairServiceProtocol
    private let subscriber = PassthroughSubject<Flight, RyanairError>()
    private var cancellable = Set<AnyCancellable>()
    var headerParams: [String: Any]
    
    init(service: RyanairService, headerParams: [String: Any]) {
        self.service = service
        self.headerParams = headerParams
    }
}

extension SearchDetailsViewModel: SearchDetailsViewModelProtocol {
    func getFlight() -> AnyPublisher<Flight, RyanairError> {
//        if let showfakeData = headerParams["showfakeData"] as? Bool, showfakeData == true {
//            return loadJson()
//        } else {
            return bindFlight()
    }
}

private extension SearchDetailsViewModel {
    func bindFlight() -> AnyPublisher<Flight, RyanairError> {
        service.getFlight()
            .sink { [weak self] completion in
                self?.subscriber.send((self?.loadJson())!)
            } receiveValue: { [weak self] flight in
                self?.subscriber.send(flight)
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

