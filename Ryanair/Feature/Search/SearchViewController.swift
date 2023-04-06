//
//  SearchViewController.swift
//  Ryanair
//
//  Created by Yuri Pedroso on 25/03/2023.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {
    
//    MARK: - Add components
    
    private lazy var originField: SearchTextField = {
        let originField = SearchTextField()
        originField.parentDelegate = self
        originField.backgroundColor = .white
        originField.text = ""
        originField.placeholder = "Origin"
        originField.translatesAutoresizingMaskIntoConstraints = false
        return originField
    }()
    
    private lazy var destinationField: SearchTextField = {
        let destinationField = SearchTextField()
        destinationField.text = ""
        destinationField.backgroundColor = .white
        destinationField.placeholder = "Destination"
        destinationField.translatesAutoresizingMaskIntoConstraints = false
        return destinationField
    }()
    
    private lazy var adultField: UITextField = {
        let adultField = UITextField()
        adultField.placeholder = "Adults: 1 by default"
        adultField.backgroundColor = .white
        adultField.translatesAutoresizingMaskIntoConstraints = false
        adultField.tag = 1
        adultField.addTarget(self, action: #selector(numberPickerViewTapped), for: .editingDidBegin)
        adultField.addDoneButtonOnKeyboard()
        return adultField
    }()
    
    private lazy var teenField: UITextField = {
        let teenField = UITextField()
        teenField.placeholder = "Teenagers: 0 by default"
        teenField.backgroundColor = .white
        teenField.translatesAutoresizingMaskIntoConstraints = false
        teenField.tag = 2
        teenField.addTarget(self, action: #selector(numberPickerViewTapped), for: .editingDidBegin)
        teenField.addDoneButtonOnKeyboard()
        return teenField
    }()
    
    private lazy var childField: UITextField = {
        let childField = UITextField()
        childField.placeholder = "Children: 0 by default"
        childField.backgroundColor = .white
        childField.translatesAutoresizingMaskIntoConstraints = false
        childField.tag = 3
        childField.addTarget(self, action: #selector(numberPickerViewTapped), for: .editingDidBegin)
        childField.addDoneButtonOnKeyboard()
        return childField
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mockLabel, jsonDataSwitch])
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var mockLabel: UILabel = {
        let mockLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        mockLabel.text = "Activate mock"
        mockLabel.translatesAutoresizingMaskIntoConstraints = false
        return mockLabel
    }()
    
    private lazy var jsonDataSwitch: UISwitch = {
        let jsonDataSwitch = UISwitch()
        jsonDataSwitch.translatesAutoresizingMaskIntoConstraints = false
        return jsonDataSwitch
    }()
    
    private lazy var dateField: UITextField = {
        let dateField = UITextField()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        dateField.text = dateFormatter.string(from: date)
        dateField.backgroundColor = .white
        dateField.translatesAutoresizingMaskIntoConstraints = false
        dateField.inputView = datePickerView
        dateField.addDoneButtonOnKeyboard()
        return dateField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        view.addSubview(button)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [originField, destinationField, dateField, adultField, teenField, childField, horizontalStackView])
        stackView.backgroundColor = .yellow
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var datePickerView: UIDatePicker = {
        let datePickerView = UIDatePicker()
        datePickerView.date = Date()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.backgroundColor = .white
        datePickerView.locale = Locale.current
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.minimumDate = Date()
        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged),
                                 for: UIControl.Event.valueChanged)
        return datePickerView
    }()
    
    private lazy var numberPickerView: UIPickerView = {
        let numberPickerView = UIPickerView()
        numberPickerView.backgroundColor = .white
        numberPickerView.dataSource = self
        numberPickerView.delegate = self
        return numberPickerView
    }()
    
    //  MARK: - Variables and lifecycles
    
    weak var coordinator: SearchCoordinator?
    var viewModel: SearchViewModelProtocol?
    
    private var date: Date = Date()
    private var cancellable = Set<AnyCancellable>()
    private var stations = [Station]()
    
    private var dateOut: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormattedForRequest = dateFormatter.string(from: date)
        return dateFormattedForRequest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        originField.hideList()
        destinationField.hideList()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SearchViewController {
    func setView() {
        title = "Search Flights"
        view.backgroundColor = .blue
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideFirstResponder)))
        setConstraints()
        addBinds()
    }
    
    func addBinds() {
        bindStations()
    }
    
    func bindStations() {
        viewModel?.bindStations()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Finished")
                }
            } receiveValue: { [weak self] stations in
                self?.originField.updateDataList(data: stations)
                self?.destinationField.updateDataList(data: stations)
            }.store(in: &cancellable)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            
            horizontalStackView.heightAnchor.constraint(equalToConstant: 50),
            
            teenField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            teenField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            teenField.heightAnchor.constraint(equalToConstant: 50),
            
            childField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            childField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            childField.heightAnchor.constraint(equalToConstant: 50),

            adultField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            adultField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            adultField.heightAnchor.constraint(equalToConstant: 50),

            originField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            originField.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 16),
            originField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            originField.heightAnchor.constraint(equalToConstant: 50),

            destinationField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            destinationField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            destinationField.heightAnchor.constraint(equalToConstant: 50),

            dateField.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16),
            dateField.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            dateField.heightAnchor.constraint(equalToConstant: 50),

            button.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
//    MARK: - Actions
    
    @objc func datePickerFromValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        dateField.text = dateFormatter.string(from: sender.date)
        date = sender.date
    }
    
    @objc func numberPickerViewTapped(_ sender: UITextField) {
        numberPickerView.tag = sender.tag
        sender.inputView = numberPickerView
        
        if let numberSelected = sender.text, let rowInt = Int(numberSelected) {
            var selectedRow = rowInt
            if sender.tag == 1 {
                selectedRow -= 1
            }
            numberPickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        }
    }
    
    @objc func hideFirstResponder() {
        self.view.endEditing(true)
    }
    
    @objc func buttonTapped(_ sender: Any) {
        let destinationField = destinationField.text ?? ""
        let originField = originField.text ?? ""
        if originField.isEmpty || destinationField.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Origin and Destination fields would not be empty!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            coordinator?.goToSearchDetails(headerParams: sendParams())
        }
    }
    
    func sendParams() -> [String: Any] {
        let showFakeData = jsonDataSwitch.isOn
        let originSelected = originField.selectedItem
        let destinationSelected = destinationField.selectedItem
        let origin = originSelected?.code ?? ""
        let destination = destinationSelected?.code ?? ""
        let adtCount = Int(adultField.text ?? "") ?? 1
        let childCount = Int(childField.text ?? "") ?? 0
        let teenCount = Int(teenField.text ?? "") ?? 0
        
        let parameters = [ "origin": origin,
                           "destination": destination,
                           "dateOut": dateOut,
                           "dateIn": "",
                           "adt": adtCount.description,
                           "teen": teenCount.description,
                           "chd": childCount.description,
                           "flexdaysbeforeout": "3",
                           "flexdaysout": "3",
                           "flexdaysbeforein": "3",
                           "flexdaysin": "3",
                           "roundTrip": "false",
                           "ToUS": "AGREED",
                           "showFakeData": showFakeData
        ] as [String: Any]
        
        return parameters
    }
}

// MARK: - UIPicker
extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(row + 1)"
        }
        return "\(row)"
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            adultField.text = "\(row + 1)"
        case 2:
            teenField.text = "\(row)"
        case 3:
            childField.text = "\(row)"
        default:
            print("Not handling this tag")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 6 }
}

// MARK: - Notification

extension SearchViewController: Notification {
    
    func updateDestinationStationsFor(selectedItem: Station) {
        let validStations = getValidStationsFor(selectedItem: selectedItem)
        
        if validStations.count > 0 {
            self.destinationField.updateDataList(data: validStations)
        }
        
        DispatchQueue.main.async {
            self.destinationField.text = nil
            self.destinationField.hideList()
        }
    }
    
    func getValidStationsFor(selectedItem: Station) -> [Station] {
        var validStations = [Station]()
        if selectedItem.markets.count > 0 {
            
            for market in selectedItem.markets {
                let validStationResults = self.stations.filter { (station) -> Bool in
                    station.code == market.code
                }
                
                if let validStation = validStationResults.first {
                    validStations.append(validStation)
                }
            }
        }
        
        return validStations
    }
}
