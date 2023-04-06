//
//  RyanairEndpoint.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 06/04/2023.
//

import Foundation

enum RyanairEndpoint {
    case stations
    case flight
}

internal extension RyanairEndpoint {
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
            var urlBuilder = URLComponents(string: url) ?? URLComponents()
            let queries = params.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
            urlBuilder.queryItems = queries
            return URLRequest(url: urlBuilder.url!, timeoutInterval: 30)
        }
    }
}
