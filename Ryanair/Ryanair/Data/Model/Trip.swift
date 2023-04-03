//
//  Trip.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Trip: Codable {
    let origin, destination: String
    let dates: [FlightDate]?
}
