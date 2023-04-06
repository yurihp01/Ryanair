//
//  SeatFee.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 06/04/2023.
//

import Foundation

struct SeatFee: Decodable {
    let vat, amt, total, totalDiscount, totalWithoutDiscount: Double
    let discountType, code: String
    let qty: Int
}
