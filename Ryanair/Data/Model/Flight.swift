//
//  Flight.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Flight: Decodable {
    let currency, serverTimeUTC, termsOfUse, routeGroup, tripType, upgradeType: String
    let currPrecision: Int
    let trips: [Trip]
}
