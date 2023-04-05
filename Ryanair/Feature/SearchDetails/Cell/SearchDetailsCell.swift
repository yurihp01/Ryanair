//
//  SearchDetailsCell.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 03/04/2023.
//

import UIKit

class SearchDetailsCell: UITableViewCell {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, flightNumberLabel, fareLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        return stackView
    }()
    
    private lazy var dateLabel: UILabel = {
        let originLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        originLabel.backgroundColor = .white
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        return originLabel
    }()
    
    private lazy var flightNumberLabel: UILabel = {
        let originLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        originLabel.backgroundColor = .white
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        return originLabel
    }()
    
    private lazy var fareLabel: UILabel = {
        let originLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        originLabel.backgroundColor = .white
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        return originLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setConstraints()
    }

    func setFlight(_ flight: FlightDetail) {
        let regularFare = flight.regularFare?.fares
            .compactMap { $0.publishedFare * (Double($0.count)) }
            .reduce(0, +) ?? 0
        fareLabel.text = "Regular fare: \(String(format: "%.2f", regularFare))"
        dateLabel.text = "Date: \(String(describing: flight.time.first?.prefix(10) ?? ""))"
        flightNumberLabel.text = "Flight Number: \(flight.flightNumber)"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
}
