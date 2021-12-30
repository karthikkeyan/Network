//
//  DataRequestTests.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-12.
//

import Foundation
import XCTest
import Network
import Combine
import CombineUtilities

final class DataRequestTests: XCTestCase {

    private var service: NetworkRequesting!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
 
        bag = []

        let platform = URLSession.shared
        let builder = NetworkServiceBuilder(platform: platform, infoProviders: [])
        let components = builder.build()
        service = components.service
    }

    func testGivenANetworkService_whenAResponseIsReceivedFromServer_thenTheResponseIsReturnedToTheConsumer() throws {
        let url = URL(string: "http://127.0.0.1:3000/data/success")!

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
