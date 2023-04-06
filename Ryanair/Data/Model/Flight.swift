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

extension Flight {
    var dates: [FlightDate] {
        self.trips.first?.dates.filter({ $0.flights.count > 0 }) ?? []
    }
    
    func getFlights(with section: Int) -> [FlightDetail] {
        return self.trips.first?.dates.filter({ $0.flights.count > 0 })[section].flights ?? []
    }
}
