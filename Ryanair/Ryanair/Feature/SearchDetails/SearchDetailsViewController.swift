//
//  SearchViewController.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 25/03/2023.
//

import UIKit
import Combine

class SearchDetailsViewController: UIViewController {
    
    //    MARK: - Add components
    
    private lazy var adultField: UITextField = {
        let adultField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        adultField.placeholder = "Adults"
        adultField.backgroundColor = .white
        adultField.translatesAutoresizingMaskIntoConstraints = false
        adultField.tag = 1
        return adultField
    }()
    
    private lazy var originLabel: UILabel = {
        let originLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        originLabel.textColor = .white
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        return originLabel
    }()
    
    private lazy var destinationLabel: UILabel = {
        let destinationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        destinationLabel.textColor = .white
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        return destinationLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        let flightsCell = UINib(nibName: "SearchDetailsCell", bundle: nil)
        self.tableView.register(flightsCell, forCellReuseIdentifier: "SearchDetailsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        return tableView
    }()
    
    weak var coordinator: SearchDetailsCoordinator?
    var viewModel: SearchDetailsViewModelProtocol?
    var currency: String!
    var trips: [Trip]!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Flights"
        
        setUpTable()
        
        //Work around the server being unavailable.
        startLoadingAnimation()
        
        if useMockData {
            getMockFlightDetails()
        } else {
            searchFlights(with: parameters)
        }
    }
    
    func setUpTable() {
        
        //HeaderView in Table
        if let parameters = self.searchParameters {
            if let origin = parameters["origin"] as? String,
               let destination = parameters["destination"] as? String {
                
            }
        }
    }
    
//    inserir bind de flights
    func searchFlights(with parameters: [String: Any]) {
        
        DispatchQueue.global(qos: .background).async {
            
            StationsService.shared.getSearch(parameters) { (resp) in
                
                switch resp {
                case .success(let resp):
                    
                    self.displayResults(currency: resp.currency, trips: resp.trips)
                    
                case .failure(let err):
                    
                    self.displayError(message: err.localizedDescription)
                }
            }
        }
    }
    
    func displayResults(currency: String!, trips: [Trip]!) {
        
        self.currency = currency
        
        DispatchQueue.main.async {
            
            
            if let trips = trips {
                self.trips = trips
//                Log.v("✅ Response: \(trips.count) TRIPS FOUND")
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
            let flightDates = dates[section]
            if let flights = flightDates.flights, flights.count > 0 {
                return flights.count
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDetailsCell", for: indexPath) as? SearchDetailsCell else { return UITableViewCell() }
            if let trips = self.trips,
               let trip = trips.first, let dates = trip.dates {
                let flightDates = dates[indexPath.section]
                if let flights = flightDates.flights, flights.count > 0 {
                    let flight = flights[indexPath.row]
                    cell.setFlight(flight, currency: self.currency)
                } else {
                    cell.setFlight(nil, currency: nil)
                }
            }
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let trips = self.trips,
           let trip = trips.first,
           let dates = trip.dates {
            return dates.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = .systemBlue
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.white
        
        label.text = "UNKNOWN"
        
        if let trips = self.trips, let trip = trips.first, let dates = trip.dates {
            if let dateForSection = dates[section].dateOut {
                let parsedDate = dateForSection.substring(upTo: 10)
                //2016-04-11T00:00:00.000 - > 2016-04-11
                let jsonDateFormatter = DateFormatter()
                jsonDateFormatter.dateFormat = "yyyy-MM-dd"
                let headerDateFormatter = DateFormatter()
                headerDateFormatter.dateFormat = "EEE dd-MM-yyyy"
                headerDateFormatter.dateStyle = .full
                
                if let date = jsonDateFormatter.date(from: String(parsedDate)) {
                    let formattedDate = headerDateFormatter.string(from: date)
                    label.text = formattedDate
                }
            }
        }
        
        view.addSubview(label)
        return view
    }
}
