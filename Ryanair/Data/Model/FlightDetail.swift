//
//  FlightDetail.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct FlightDetail: Decodable {
    let time, timeUTC: [String]
    let duration, flightNumber, flightKey: String
    let operatedBy: String?
    let regularFare: FareOption?
    let faresLeft, infantsLeft : Int
    let segments: [Segment]
}
