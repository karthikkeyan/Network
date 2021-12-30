//
//  EventTests.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-21.
//

import Combine
import Foundation
import Network
import CombineUtilities
import XCTest

final class EventTests: XCTestCase {
    private var service: NetworkRequesting!
    private var eventPublisher: AnyPublisher<NetworkEvent, Never>!
    private var platform: MockURLSession!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        bag = []
        platform = MockURLSession()
 
        let builder = NetworkServiceBuilder(platform: platform, infoProviders: [])
        let components = builder.build()
        service = components.service
        eventPublisher = components.eventPublisher
    }

    func testGivenANetworkService_whenARequestIsReceived_thenTheFinalRequestIsEmittedToRequestPublisher() {
        let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
        let requestID = UUID().uuidString
        let requestIDKey = "X-TEST-REQUEST-ID"

        var request = URLRequest(url: url)
        request.addValue(requestID, forHTTPHeaderField: requestIDKey)

        var isEventReceived = false
        eventPublisher
            .onValue {
                switch $0 {
                case .request(let value):
                    XCTAssertEqual(value.url, url)
                    XCTAssertEqual(value.allHTTPHeaderFields?[requestIDKey], requestID)
                    isEventReceived = true
                case .response, .error:
                    break
                }
            }.start(with: &bag)

        service
            .send(request: request)
            .start(with: &bag)
        
        XCTAssertTrue(isEventReceived)
    }

    func testGivenANetworkService_whenAResponseIsReceived_thenTheResponseIsEmittedToReponsePublisher() {
        let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
        let request = URLRequest(url: url)

        var isEventReceived = false
        eventPublisher
            .onValue {
                switch $0 {
                case .request:
                    break
                case .response:
                    isEventReceived = true
                case .error:
                    XCTFail("Shouldn't receive error")
                }
            }.start(with: &bag)

        service
            .send(request: request)
            .start(with: &bag)

        XCTAssertTrue(isEventReceived)
    }

    func testGivenANetworkService_whenAnErrorOccuredDuringNetworkCall_thenTheErrorIsEmittedToErrorPublisher() {
        let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
        let request = URLRequest(url: url)

        platform.result = .failure(URLError(.badServerResponse))

        var isEventReceived = false
        eventPublisher
            .onValue {
                switch $0 {
                case .request:
                    break
                case .response:
                    XCTFail("Shouldn't receive response")
                case .error:
                    isEventReceived = true
                }
            }.start(with: &bag)

        service
            .send(request: request)
            .start(with: &bag)

        XCTAssertTrue(isEventReceived)
    }
}
