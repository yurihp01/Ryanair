//
//  Flight.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Flight: Codable {
    let currency, serverTimeUTC: String
    let currPrecision: Int
    let trips: [Trip]?
}
