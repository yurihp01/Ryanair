//
//  Trip.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Trip: Decodable {
    let origin, originName, destination, destinationName, routeGroup, tripType, upgradeType: String
    let dates: [FlightDate]
}
