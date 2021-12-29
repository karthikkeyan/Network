//
//  UploadRequestTests.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-29.
//

import Foundation
import XCTest
import Network
import Combine

final class UploadRequestTests: XCTestCase {
    private var service: NetworkRequesting!
    private var platform: MockURLSession!
    private var bag: Set<AnyCancellable>!
    private var sessionProvider: SessionProvider!
    private var deviceInfoProvider: DeviceInfoProvider!

    override func setUp() {
        super.setUp()

        bag = []
        platform = MockURLSession()

        let builder = NetworkServiceBuilder(platform: platform, infoProviders: [])
        let components = builder.build()
        service = components.service
    }

    func testGivenANetwokService_whenAUploadRequestIsReceived_thenTheRequestIsSentToServer() throws {
        let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
        let requestID = UUID().uuidString
        let requestIDKey = "X-TEST-REQUEST-ID"
        
        let fileURL = Bundle.module.url(forResource: "upload", withExtension: "png")!
        var request = URLRequest(url: url)
        request.addValue(requestID, forHTTPHeaderField: requestIDKey)
        request.httpMethod = "POST"

        service
            .upload(file: fileURL, with: request)
            .start(with: &bag)

        let recentRequest = try XCTUnwrap(platform.recentRequest)
        let recentFileURL = try XCTUnwrap(platform.recentFileURL)
        XCTAssertEqual(request.url, recentRequest.url)
        XCTAssertEqual(request.allHTTPHeaderFields?[requestIDKey], requestID)
        XCTAssertEqual(fileURL, recentFileURL)
    }
}
