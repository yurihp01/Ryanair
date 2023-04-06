//
//  RyanairService.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation
import Combine

enum RyanairEndpoint {
    case stations
    case flight
}

private extension RyanairEndpoint {
    var url: String {
        switch self {
        case .stations:
            return "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json"
        case .flight:
            return "https://nativeapps.ryanair.com/api/v4/en-IE/Availability"
        }
    }
    
    func setHeader(params: [String:Any]) -> URLRequest {
        switch self {
        case .stations:
            return URLRequest(url: URL(string: url)!, timeoutInterval: 30)

        case .flight:
            let urlBuilder = URLComponents(string: url) ?? URLComponents()
            var request = URLRequest(url: urlBuilder.url!, timeoutInterval: 30)
            request.httpMethod = "GET"
            
            params.forEach { request.setValue($0.value as? String, forHTTPHeaderField: $0.key) }
            return request
        }
    }
}

protocol RyanairServiceProtocol {
    func getStations() -> AnyPublisher<[Station], RyanairError>
    func getFlight(params: inout [String : Any]) -> AnyPublisher<[Flight], RyanairError>
}

class RyanairService {
    private var cancellable = Set<AnyCancellable>()
    private let flightSubject = CurrentValueSubject<[Flight], RyanairError>([])
    private let stationSubject = CurrentValueSubject<[Station], RyanairError>([])

}

extension RyanairService: RyanairServiceProtocol {
    func getStations() -> AnyPublisher<[Station], RyanairError> {
        URLSession.shared.dataTaskPublisher(for: getRequest(with: .stations, params: [:]))
            .tryMap { data, response -> Data in
                self.validateFields(data: data, response: response, subject: self.stationSubject)
                return data
            }
            .decode(type: Stations.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [weak stationSubject] completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure:
                    stationSubject?.send(completion: .failure(.invalidData))
                }
            }, receiveValue: { [weak stationSubject] stations in
                stationSubject?.send(stations.stations)
            }).store(in: &cancellable)
        return stationSubject.eraseToAnyPublisher()
    }
    
    func getFlight(params: inout [String : Any]) -> AnyPublisher<[Flight], RyanairError> {
        if let showfakeData = params["showFakeData"] as? Bool, showfakeData == true,
           let flight = loadJson() {
            flightSubject.send([flight])
            params["origin"] = flight.trips?.first?.origin
            params["destination"] = flight.trips?.first?.destination
            return flightSubject.eraseToAnyPublisher()
        }
        
        params.removeValue(forKey: "showFakeData")
        URLSession.shared.dataTaskPublisher(for: getRequest(with: .flight, params: params))
            .tryMap { data, response -> Data in
                self.validateFields(data: data, response: response, subject: self.flightSubject)
                return data
            }
            .decode(type: Flight.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [weak flightSubject] completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure:
                    flightSubject?.send(completion: .failure(.invalidData))
                }
            }, receiveValue: { [weak flightSubject] flight in
                flightSubject?.send([flight])
            }).store(in: &cancellable)
        return flightSubject.eraseToAnyPublisher()
    }
}

private extension RyanairService {
    func getRequest(with endpoint: RyanairEndpoint, params: [String : Any]) -> URLRequest {
        var request = endpoint.setHeader(params: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        return request
    }
    
    func validateFields<T>(data: Data?, response: URLResponse?, subject: CurrentValueSubject<[T], RyanairError>) {
        if data == nil {
            subject.send(completion: .failure(RyanairError.invalidData))
        }
        
        if response as? HTTPURLResponse == nil {
            subject.send(completion: .failure(RyanairError.badResponse))
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            subject.send(completion: .failure(RyanairError.invalidStatusCode(statusCode: response.statusCode)))
        }
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
