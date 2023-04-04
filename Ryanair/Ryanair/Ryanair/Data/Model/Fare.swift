//
//  Fare.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Fare: Codable {
    let amount, publishedFare: Double
    let count: Int
    let type: String
    let hasDiscount: Bool
}
