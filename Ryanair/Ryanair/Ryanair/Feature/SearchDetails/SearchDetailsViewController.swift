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
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [originLabel, destinationLabel])
        stackView.backgroundColor = .systemYellow
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var originLabel: UILabel = {
        let originLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        return originLabel
    }()
    
    private lazy var destinationLabel: UILabel = {
        let destinationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        return destinationLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchDetailsCell.self, forCellReuseIdentifier: "SearchDetailsCell")
        tableView.backgroundColor = .systemYellow
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        return tableView
    }()
    
    weak var coordinator: SearchDetailsCoordinator?
    var viewModel: SearchDetailsViewModelProtocol?
    private var cancellable = Set<AnyCancellable>()
    private var flight: Flight?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Flights"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.backgroundColor = .blue
        bindFlights()
        setConstraints()
    }
    
    func bindFlights() {
        viewModel?.getFlight()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                case .finished:
                    print("finished")
                }
            }, receiveValue: { [weak self] flight in
                self?.flight = flight
                self?.setUpTableView()
            }).store(in: &cancellable)
    }
    
    func setUpTableView() {
        
        //HeaderView in Table
        if let parameters = viewModel?.headerParams,
           let origin = parameters["origin"] as? String,
           let destination = parameters["destination"] as? String {
            tableView.isHidden = false
            tableView.reloadData()
            originLabel.text = "Origin: \(origin)"
            destinationLabel.text = "Destination: \(destination)"
        }
    }
}

extension SearchDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trip = self.flight?.trips?.first,
              let flightDates = trip.dates?[section],
              let flights = flightDates.flights, flights.count > 0 else { return 1 }
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDetailsCell", for: indexPath) as? SearchDetailsCell else { return UITableViewCell() }
        cell.backgroundColor = .green
        if let flightDates = flight?.trips?.first?.dates?[indexPath.section],
           let flights = flightDates.flights, flights.count > 0 {
            let flight = flights[indexPath.row]
            cell.setFlight(flight)
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.flight?.trips?.first?.dates?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = .yellow
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont.systemFont(ofSize: 14.0)
//        label.textColor = UIColor.white
        
        label.text = "UNKNOWN"
        
        if let dateOut = flight?.trips?.first?.dates?[section].dateOut {
            let date = dateOut.prefix(upTo: dateOut.index(dateOut.startIndex, offsetBy: 10))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let headerDateFormatter = DateFormatter()
            headerDateFormatter.dateFormat = "EEE dd-MM-yyyy"
            headerDateFormatter.dateStyle = .full
            
            if let date = dateFormatter.date(from: String(date)) {
                let formattedDate = headerDateFormatter.string(from: date)
                label.text = formattedDate
            }
        }
        
        view.addSubview(label)
        return view
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            horizontalStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            horizontalStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 50),
            horizontalStackView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -16),
            
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
