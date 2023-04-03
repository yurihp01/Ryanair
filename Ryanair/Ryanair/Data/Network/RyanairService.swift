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
    case flights
}

private extension RyanairEndpoint {
    var url: String {
        switch self {
        case .stations:
            return "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json"
        case .flights:
            return "https://nativeapps.ryanair.com/api/v4/en-IE/Availability?origin=DUB&destination=STN&dateout=2023-02-02&datein=&flexdaysbeforeout=3&flexdaysout=3&flexdaysbeforein=3&flexdaysin=3&adt=1&teen=0&chd=0&inf=0&roundtrip=false&ToUs=AGREED&Disc=0"
        }
    }
}

protocol RyanairServiceProtocol {
    func getStations() -> AnyPublisher<[Station], RyanairError>
    func getFlights() -> AnyPublisher<[Flight], RyanairError>
}

class RyanairService {
    private var cancellable = Set<AnyCancellable>()
}

extension RyanairService: RyanairServiceProtocol {
    func getStations() -> AnyPublisher<[Station], RyanairError> {
        let stationSubject = PassthroughSubject<[Station], RyanairError>()
        URLSession.shared.dataTaskPublisher(for: getRequest(with: .stations))
            .tryMap { data, response -> Data in
                self.validateFields(data: data, response: response, subject: stationSubject)
                return data
            }
            .decode(type: Stations.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure:
                    stationSubject.send(completion: .failure(.invalidData))
                }
            }, receiveValue: { stations in
                stationSubject.send(stations.stations)
            }).store(in: &cancellable)
        return stationSubject.eraseToAnyPublisher()
    }
    
    func getFlights() -> AnyPublisher<[Flight], RyanairError> {
        let tripsSubject = PassthroughSubject<[Flight], RyanairError>()
        URLSession.shared.dataTaskPublisher(for: getRequest(with: .flights))
            .tryMap { data, response -> Data in
                self.validateFields(data: data, response: response, subject: tripsSubject)
                return data
            }
            .decode(type: [Flight].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure:
                    tripsSubject.send(completion: .failure(.invalidData))
                }
            }, receiveValue: { flight in
                tripsSubject.send(flight)
            }).store(in: &cancellable)
        return tripsSubject.eraseToAnyPublisher()
    }
}

private extension RyanairService {
    func getRequest(with endpoint: RyanairEndpoint) -> URLRequest {
        let url = URL(string: endpoint.url)!
        
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        return request
    }
    
    func validateFields<T>(data: Data?, response: URLResponse?, subject: PassthroughSubject<[T], RyanairError>) {
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
}
