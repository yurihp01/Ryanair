//
//  Market.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 31/03/2023.
//

import Foundation

struct Market: Decodable {
    let code: String
    let group: String?
    var stops: [Stop]?
    
    var onlyConnecting: Bool?

}
