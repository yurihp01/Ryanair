//
//  SearchDetailsViewModelTest.swift
//  RyanairTests
//
//  Created by Yuri Pedroso on 07/04/2023.
//

import Combine
import XCTest
@testable import Ryanair

final class SearchDetailsViewModelTest: XCTestCase {

    private var sut: SearchDetailsViewModelProtocol!
    private var service: RyanairServiceProtocol!
    private var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        service = RyanairServiceMock(scenario: .success([]))
        sut = SearchDetailsViewModel(service: service, headerParams: [:])
    }
    
    func testBindFlightsSuccessful() throws {
        var params: [String: Any] = ["":""]
        let flights = try awaitPublisher(service.getFlight(params: &params))
        XCTAssertTrue(flights.count > 0, "Flights should be more than 0!")
    }
     
    func testBindFlightsFailure() throws {
        var params: [String: Any] = ["":""]
        service = RyanairServiceMock(scenario: .failure(.badResponse))
        let expectation = expectation(description: "Get Flights Failure")
        service.getFlight(params: &params).sink { _ in
            expectation.fulfill()
        } receiveValue: { _ in
        }.cancel()
        
        waitForExpectations(timeout: 0.5)
    }
}
