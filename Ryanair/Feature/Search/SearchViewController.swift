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
        let originField = SearchTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        originField.parentDelegate = self
        originField.backgroundColor = .white
        originField.text = ""
        originField.placeholder = "Origin"
        originField.translatesAutoresizingMaskIntoConstraints = false
        return originField
    }()
    
    private lazy var destinationField: SearchTextField = {
        let destinationField = SearchTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        destinationField.text = ""
        destinationField.backgroundColor = .white
        destinationField.placeholder = "Destination"
        destinationField.translatesAutoresizingMaskIntoConstraints = false
        return destinationField
    }()
    
    private lazy var adultField: UITextField = {
        let adultField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        adultField.placeholder = "Adults: 1 by default"
        adultField.backgroundColor = .white
        adultField.translatesAutoresizingMaskIntoConstraints = false
        adultField.tag = 1
        adultField.addTarget(self, action: #selector(pickANumber), for: .editingDidBegin)
        return adultField
    }()
    
    private lazy var teenField: UITextField = {
        let teenField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        teenField.placeholder = "Teenagers: 0 by default"
        teenField.backgroundColor = .white
        teenField.translatesAutoresizingMaskIntoConstraints = false
        teenField.tag = 2
        teenField.addTarget(self, action: #selector(pickANumber), for: .editingDidBegin)
        return teenField
    }()
    
    private lazy var childField: UITextField = {
        let childField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        childField.placeholder = "Children: 0 by default"
        childField.backgroundColor = .white
        childField.translatesAutoresizingMaskIntoConstraints = false
        childField.tag = 3
        childField.addTarget(self, action: #selector(pickANumber), for: .editingDidBegin)
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
        let dateField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        dateField.text = dateFormatter.string(from: date)
        dateField.backgroundColor = .white
        dateField.translatesAutoresizingMaskIntoConstraints = false
        dateField.addTarget(self, action: #selector(pickADate), for: .editingDidBegin)
        return dateField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .yellow
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [originField, destinationField, dateField, adultField, teenField, childField, horizontalStackView])
        stackView.backgroundColor = .systemYellow
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    //  MARK: - Variables and lifecycles
    
    private var date: Date = Date()
    private var cancellable = Set<AnyCancellable>()
    private var stations = [Station]()
    weak var coordinator: SearchCoordinator?
    var viewModel: SearchViewModelProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideFirstResponder)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBinds()
        setView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Pickers
    @IBAction func pickADate(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.backgroundColor = .white
        datePickerView.locale = Locale.current
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.minimumDate = Date()
        dateField.inputView = datePickerView
        
        //Show current date to begin with
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        
        datePickerView.date = Date()
        
        //Listen for date changes
        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged),
                                 for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerFromValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        dateField.text = dateFormatter.string(from: sender.date)
        date = sender.date
    }
    
    func getRequestDate() -> String {
        //Used in the search parameters, requires date format 2020-02-29
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFormattedForRequest = dateFormatter.string(from: date)
        return dateFormattedForRequest
    }
    
    @IBAction func pickANumber(_ sender: UITextField) {
        let numberPickerView: UIPickerView = UIPickerView()
        numberPickerView.backgroundColor = .white
        numberPickerView.dataSource = self
        numberPickerView.delegate = self
        numberPickerView.tag = sender.tag
        sender.inputView = numberPickerView
        
        //Show selected row
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
    
    //    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        hideFirstResponder()
    //
    //        let parameters = gatherParameters()
    //
    //        // Get the new view controller using segue.destination.
    //        // Pass the selected object to the new view controller.
    //        if let searchResultsVC = segue.destination as? SearchResultsVC {
    //            searchResultsVC.searchParameters = parameters
    //            searchResultsVC.setMockData(onOrOff: self.mockDataSwitch.isOn)
    //        }
    //    }
    
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
                           "dateOut": getRequestDate(),
                           "dateIn": "",
                           "adt": adtCount,
                           "teen": teenCount,
                           "chd": childCount,
                           "flexdaysbeforeout": 3,
                           "flexdaysout": 3,
                           "flexdaysbeforein": 3,
                           "flexdaysin": 3,
                           "roundTrip": false,
                           "ToUS": "AGREED",
                           "showfakeData": showFakeData
        ] as [String: Any]
        
        return parameters
    }
}
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return 6
        }
        return 7
    }
}

extension SearchViewController: ChildNotifiesParent {
    
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

private extension SearchViewController {
    func setView() {
        title = "Search Flights"
        view.backgroundColor = .blue
        setConstraints()
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
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
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
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

