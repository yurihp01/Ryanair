//
//  FlightDate.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct FlightDate: Decodable {
    let dateOut: String
    let flights: [FlightDetail]
}
