//
//  Station.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

public struct Station: Decodable {
    let alternateName, notices, countryAlias, tripCardImageUrl: String?
    let name, code, countryCode, countryGroupCode, countryGroupName, countryName, latitude, longitude, timeZoneCode: String
    var markets: [Market] = []
    var alias: [String] = []
    let mobileBoardingPass: Bool
}

public struct Stations: Decodable {
    var stations: [Station] = []
}
