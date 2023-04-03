//
//  SearchDetailsCell.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 03/04/2023.
//

import UIKit

class SearchDetailsCell: UITableViewCell {

    var flight: FlightDetail!
    var currency: String!

    var detailsStackView: UIStackView!
    var labelOutTime: UILabel!
    var labelInTime: UILabel!
    var labelFlightNumber: UILabel!
    var labelAdultFare: UILabel!
    var labelTeenFare: UILabel!
    var labelChildFare: UILabel!
    var labelTotal: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialiseCell()
    }

    func initialiseCell() {
        labelFlightNumber.text = nil
        labelAdultFare.text = nil
        labelTeenFare.text = nil
        labelChildFare.text = nil
        labelTotal.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setFlight(_ flight: FlightDetail!, currency: String!) {

        self.currency = currency

        if let flight = flight {

            self.flight = flight

            let adtCount = self.getCountFor(type: "ADT")
            let teenCount = self.getCountFor(type: "TEEN")
            let chdCount = self.getCountFor(type: "CHD")

            let adtFare = self.getFareFor(type: "ADT")
            let teenFare = self.getFareFor(type: "TEEN")
            let chdFare = self.getFareFor(type: "CHD")

            var total = (adtFare * Double(adtCount))
                total += (teenFare * Double(teenCount))
                total += (chdFare * Double(chdCount))

            DispatchQueue.main.async {
                if let outTime = flight.time.first, let inTime = flight.time.last {
                    //2016-04-11T00:00:00.000 - > 00:00
                    let displayOutTime = outTime[11..<16]
                    let displayInTime = inTime[11..<16]
                    self.labelOutTime.text = displayOutTime
                    self.labelInTime.text = displayInTime
                }
                self.detailsStackView.isHidden = false
                self.labelFlightNumber?.text = flight.flightNumber
                self.labelAdultFare.text = "(\(adtCount)) \(self.getCurrency()) \(adtFare)"
                self.labelTeenFare.text = "(\(teenCount)) \(self.getCurrency()) \(teenFare)"
                self.labelChildFare.text = "(\(chdCount)) \(self.getCurrency()) \(chdFare)"
                self.labelTotal.text = String(format: "\(self.getCurrency()) %.2f", total)
            }
        } else {
            DispatchQueue.main.async {
                self.labelFlightNumber?.text = "No flights Available"
                self.labelOutTime.text = nil
                self.labelInTime.text = nil
                self.detailsStackView.isHidden = true
            }
        }

    }

    func getCurrency() -> String {
        guard let currency = self.currency else {
            return ""
        }

        switch currency {
        case "EUR":
            return "€"
        default:
            return currency
        }
    }

    func getFareFor(type: String) -> Double {
        if let regularFare = self.flight.regularFare,
           regularFare.fares.count > 0 {

            let results = regularFare.fares.filter { (fare) -> Bool in
                fare.type == type
            }

            if results.count == 1,
                let fareFound = results.first {
                return fareFound.publishedFare
            }
        }
        return 0
    }

    func getCountFor(type: String) -> Int {
        if let regularFare = self.flight.regularFare,
            
            regularFare.fares.count > 0 {

            let results = regularFare.fares.filter { (fare) -> Bool in
                fare.type == type
            }

            if results.count == 1,
                let fareFound = results.first {
                return fareFound.count
            }
        }
        return 0
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
