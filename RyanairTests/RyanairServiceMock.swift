//
//  RyanairServiceMock.swift
//  RyanairTests
//
//  Created by Yuri Pedroso on 06/04/2023.
//

import Combine
import Foundation
import XCTest
@testable import Ryanair

class RyanairServiceMock: RyanairServiceProtocol {
    enum Scenario {
        case success([Any])
        case failure(RyanairError)
    }
    
    let scenario: Scenario
        
        init(scenario: Scenario) {
            self.scenario = scenario
        }
    
    private var cancellables: Set<AnyCancellable>!
    
    func getStations() -> AnyPublisher<[Station], RyanairError> {
        switch scenario {
        case .success:
            return Just(loadStationJson())
                .setFailureType(to: RyanairError.self)
                .eraseToAnyPublisher()
        case .failure:
            return Fail(error: .invalidData)
                .eraseToAnyPublisher()
        }
    }
    
    func getFlight(params: inout [String : Any]) -> AnyPublisher<[Flight], RyanairError> {
        guard let flight = loadFlightJson() else { return Fail(error: .invalidData).eraseToAnyPublisher() }
        switch scenario {
        case .success:
            return Just([flight])
                .setFailureType(to: RyanairError.self)
                .eraseToAnyPublisher()
        case .failure:
            return Fail(error: .invalidData)
                .eraseToAnyPublisher()
        }
    }
    
    func loadFlightJson() -> Flight? {
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

    func loadStationJson() -> [Station] {
        if let url = Bundle.main.url(forResource: "searchStations.json", withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Stations.self, from: data)
                return jsonData.stations
            } catch {
                print("error:\(error)")
            }
        }
        return []
    }
}
