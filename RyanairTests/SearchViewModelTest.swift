//
//  SearchViewModelTest.swift
//  RyanairTests
//
//  Created by Yuri Pedroso on 25/03/2023.
//

import Combine
import XCTest
@testable import Ryanair

final class SearchViewModelTest: XCTestCase {

    private var sut: SearchViewModelProtocol!
    private var service: RyanairServiceProtocol!
    private var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        service = RyanairServiceMock(scenario: .success([]))
        sut = SearchViewModel(service: service)
    }
    
    func testBindStationsSuccessful() throws {
        let stations = try awaitPublisher(service.getStations())
        XCTAssertTrue(stations.count > 0, "Stations should be more than 0!")
    }
     
    func testBindStationsFailure() throws {
        service = RyanairServiceMock(scenario: .failure(.badResponse))
        let expectation = expectation(description: "Get Stations Failure")
        service.getStations().sink { _ in
            expectation.fulfill()
        } receiveValue: { _ in
        }.cancel()
        
        waitForExpectations(timeout: 0.5)
    }
}
