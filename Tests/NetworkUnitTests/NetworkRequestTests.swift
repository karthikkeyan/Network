//
//  NetworkRequestTests.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import XCTest
import Network
import Combine
import CombineUtilities

final class NetworkRequestTests: XCTestCase {

     private var service: NetworkRequesting!
     private var platform: MockURLSession!
     private var bag: Set<AnyCancellable>!
     private var sessionProvider: SessionProvider!
     private var deviceInfoProvider: DeviceInfoProvider!

     override func setUp() {
         super.setUp()

         bag = []
         platform = MockURLSession()
         sessionProvider = SessionProvider()
         deviceInfoProvider = DeviceInfoProvider()
 
         let builder = NetworkServiceBuilder(platform: platform, infoProviders: [sessionProvider, deviceInfoProvider])
         let components = builder.build()
         service = components.service
     }

     func testGivenANetwokService_whenARequestIsReceived_thenTheRequestIsSentToServer() throws {
         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let requestID = UUID().uuidString
         let requestIDKey = "X-TEST-REQUEST-ID"

         var request = URLRequest(url: url)
         request.addValue(requestID, forHTTPHeaderField: requestIDKey)
         service
             .send(request: request)
             .start(with: &bag)

         let recentRequest = try XCTUnwrap(platform.recentRequest)
         XCTAssertEqual(request.url, recentRequest.url)
         XCTAssertEqual(request.allHTTPHeaderFields?[requestIDKey], requestID)
     }

     func testGivenANetworkService_whenAResponseIsReceivedFromServer_thenTheResponseIsReturnedToTheConsumer() throws {
         let expectedData = "Welcome to Software Engineering YouTube Channel"
         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let requestID = UUID().uuidString
         let requestIDKey = "X-TEST-REQUEST-ID"

         var response: NetworkResponse?
         var isResponseReceived = false
         var request = URLRequest(url: url)
         request.addValue(requestID, forHTTPHeaderField: requestIDKey)
         service
             .send(request: request)
             .onValue {
                 response = $0
                 isResponseReceived = true
             }.start(with: &bag)

         let unwrappedResponse = try XCTUnwrap(response)
         let unwrappedData = try XCTUnwrap(unwrappedResponse.payload)
         let string = try XCTUnwrap(String(data: unwrappedData, encoding: .utf8))
         XCTAssertEqual(string, expectedData)
         XCTAssertTrue(isResponseReceived)
     }
    
     func testGivenANetworkService_whenAnErrorOccuredDuringNetworkCall_thenTheErrorIsReturnedWithHTTPStatusCode() throws {
         platform.result = .success((Data(), 404))

         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let requestID = UUID().uuidString
         let requestIDKey = "X-TEST-REQUEST-ID"

         var request = URLRequest(url: url)
         request.addValue(requestID, forHTTPHeaderField: requestIDKey)

         var error: NetworkError?
         service
             .send(request: request)
             .onValue { _ in
                 XCTFail("Network request suppose to fail")
             }.onError {
                 error = $0
             }.start(with: &bag)
        
         let unwrappedError = try XCTUnwrap(error)
         XCTAssertEqual(unwrappedError.statusCode, 404)
     }
    
     func testGivenANetworkService_whenAnLocalErrorOccuredDuringNetworkCall_thenTheErrorIsReturnedWithLocalErrorCode() throws {
         platform.result = .failure(URLError(.networkConnectionLost))

         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let requestID = UUID().uuidString
         let requestIDKey = "X-TEST-REQUEST-ID"

         var request = URLRequest(url: url)
         request.addValue(requestID, forHTTPHeaderField: requestIDKey)

         var error: NetworkError?
         service
             .send(request: request)
             .onValue { _ in
                 XCTFail("Network request suppose to fail")
             }.onError {
                 error = $0
             }.start(with: &bag)

         let unwrappedError = try XCTUnwrap(error)
         let urlError = try XCTUnwrap(unwrappedError.underlyingError as? URLError)
         XCTAssertEqual(urlError.errorCode, URLError.networkConnectionLost.rawValue)
         XCTAssertEqual(unwrappedError.statusCode, NetworkError.localErrorCode)
     }

     func testGivenANetworkService_whenAnUnexpectedServerErrorOcurredDuringNetworkCall_thenTheErrorIsReturnedWithUnexpectedErrorCode() throws {
         platform.isHttpResonse = false
         platform.result = .success((Data(), 1000))

         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let requestID = UUID().uuidString
         let requestIDKey = "X-TEST-REQUEST-ID"

         var request = URLRequest(url: url)
         request.addValue(requestID, forHTTPHeaderField: requestIDKey)

         var error: NetworkError?
         service
             .send(request: request)
             .onValue { _ in
                 XCTFail("Network request suppose to fail")
             }.onError {
                 error = $0
             }.start(with: &bag)

         let unwrappedError = try XCTUnwrap(error)
         let urlError = try XCTUnwrap(unwrappedError.underlyingError as? URLError)
         XCTAssertEqual(urlError.errorCode, URLError.badServerResponse.rawValue)
         XCTAssertEqual(unwrappedError.statusCode, NetworkError.unexpectedServerErrorCode)
     }

     func testGivenANetwokService_whenARequestIsReceived_thenAdditionlInfoIsAddedBeforeTheRequestIsSentToServer() throws {
         let token = UUID().uuidString
         let sessionHeaderKey = "X-SESSION-ID"
         sessionProvider.headerKey = sessionHeaderKey
         sessionProvider.token = token

         let deviceType = "iPhone 12"
         let deviceTypeHeaderKey = "X-DEVICE-TYPE"
         deviceInfoProvider.headerKey = deviceTypeHeaderKey
         deviceInfoProvider.deviceType = deviceType

         let url = URL(string: "api.testservice.com/v1/path/to/endpoint")!
         let request = URLRequest(url: url)
         service
             .send(request: request)
             .start(with: &bag)

         let recentRequest = try XCTUnwrap(platform.recentRequest)
         XCTAssertEqual(recentRequest.allHTTPHeaderFields?[sessionHeaderKey], token)
         XCTAssertEqual(recentRequest.allHTTPHeaderFields?[deviceTypeHeaderKey], deviceType)
     }
}
