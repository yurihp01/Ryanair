//
//  Segment.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 06/04/2023.
//

import Foundation

struct Segment: Codable {
    let segmentNr: Int
    let origin, destination, flightNumber, duration: String
    let time, timeUTC: [String]
}
