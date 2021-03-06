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
import CombineUtilities

final class UploadRequestTests: XCTestCase {

    private var service: NetworkRequesting!
    private var bag: Set<AnyCancellable>!
    private var fileURL: URL!

    override func setUp() {
        super.setUp()
 
        bag = []
        fileURL = Bundle.module.url(forResource: "upload", withExtension: "png")!

        let platform = URLSession.shared
        let builder = NetworkServiceBuilder(platform: platform, infoProviders: [])
        let components = builder.build()
        service = components.service
    }

    func test_givenANetworkService_whenNetworkErrorOccuredDuringUploadTask_thenTheErrorWithHTTPStatusCodeIsReturnToConsumer() throws {
        let url = URL(string: "http://127.0.0.1:3000/upload/failure")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let failureExpectation = expectation(description: "Upload Failure")
        var error: NetworkError?
        service
            .upload(file: fileURL, with: request)
            .onValue { _ in
                XCTFail("Network request suppose to fail")
                failureExpectation.fulfill()
            }.onError {
                error = $0
                failureExpectation.fulfill()
            }.start(with: &bag)

        wait(for: [failureExpectation], timeout: .instrumentationTestRuntime)

        let unwrappedError = try XCTUnwrap(error)
        XCTAssertEqual(unwrappedError.statusCode, 400)
    }

    func testGivenANetworkService_whenAnLocalErrorOccuredDuringUploadRequest_thenTheErrorIsReturnedWithLocalErrorCode() throws {
        let url = URL(string: "http://127.0.0.2:5000/v1/path/to/endpoint")!
        var request = URLRequest(url: url)
        request.timeoutInterval = .instrumentationTestRuntime - 1
        request.httpMethod = "POST"

        let failureExpectation = expectation(description: "Upload Failure")
        var error: NetworkError?
        service
            .upload(file: fileURL, with: request)
            .onValue { _ in
                XCTFail("Upload request suppose to fail")
                failureExpectation.fulfill()
            }.onError {
                error = $0
                failureExpectation.fulfill()
            }.start(with: &bag)

        wait(for: [failureExpectation], timeout: .instrumentationTestRuntime)

        let unwrappedError = try XCTUnwrap(error)
        let urlError = try XCTUnwrap(unwrappedError.underlyingError as? URLError)
        XCTAssertEqual(urlError.errorCode, URLError.timedOut.rawValue)
        XCTAssertEqual(unwrappedError.statusCode, NetworkError.localErrorCode)
    }
}
