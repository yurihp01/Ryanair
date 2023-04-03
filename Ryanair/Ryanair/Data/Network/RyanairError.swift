//
//  RyanairError.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

enum RyanairError: Error {
    case badURL
    case badResponse
    case invalidStatusCode(statusCode: Int)
    case invalidData
    case invalidJson
}

extension RyanairError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badResponse:
            return "Invalid Response"
        case .badURL:
            return "Invalid URL"
        case .invalidData:
            return "Invalid Data"
        case .invalidJson:
            return "JSON decoding error"
        case .invalidStatusCode(let statusCode):
            return " Invalid status code: \(statusCode)"
        }
    }
}
