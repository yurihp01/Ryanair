//
//  FlightDetail.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct FlightDetail: Codable {
    let time, timeUTC: [String]
    let duration, flightNumber, flightKey: String
    let regularFare, businessFare: FareOption?
    let faresLeft, infantsLeft : Int
}
