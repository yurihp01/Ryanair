//
//  FareOption.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct FareOption: Codable {
    let fareKey, fareClass: String
    let fares: [Fare]
}
