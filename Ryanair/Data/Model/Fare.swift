//
//  Fare.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Fare: Decodable {
    let amount, publishedFare: Double
    let count: Int
    let discountAmount, discountInPercent: Double
    let type: String
    let hasDiscount, hasPromoDiscount, hasBogof: Bool
    let mandatorySeatFee: SeatFee?
}

// TODO: corrigir search field, criar testes unitarios e testar endpoint se possivel
