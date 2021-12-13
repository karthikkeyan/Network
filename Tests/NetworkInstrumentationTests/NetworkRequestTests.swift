//
//  NetworkRequestTests.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-12.
//

import Foundation
import XCTest
import Network
import Combine
import NetworkTestUtilities

final class NetworkRequestTests: XCTestCase {

    private var service: NetworkRequesting!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
 
        bag = []

        let platform = URLSession.shared
        let builder = NetworkServiceBuilder(platform: platform)
        service = builder.build()
    }

    func testGivenANetworkService_whenAResponseIsReceivedFromServer_thenTheResponseIsReturnedToTheConsumer() throws {
        let url = URL(string: "https://run.mocky.io/v3/0bdf8704-7b78-4d09-b773-2b3567e2d9b1")!

        var isResponseReceived = false
        let request = URLRequest(url: url)
        let successExpectation = expectation(description: "Successfull network call")
        service
            .send(request: request)
            .onError {
                XCTFail($0.underlyingError.localizedDescription)
                successExpectation.fulfill()
            }.onValue { _ in
                isResponseReceived = true
                successExpectation.fulfill()
            }.start(with: &bag)

        wait(for: [successExpectation], timeout: .instrumentationTestRuntime)
        XCTAssertTrue(isResponseReceived)
    }
}
