//
//  MockURLSession.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Network
import Combine

final class MockURLSession: NetworkPlatform {
    
    var recentRequest: URLRequest?
    var isHttpResonse = true

    var result: Result<(Data, Int), URLError> = {
        let mockData: Data = "Welcome to Software Engineering YouTube Channel".data(using: .utf8)!
        return .success((mockData, 200))
    }()

    func executeRequest(_ request: URLRequest) -> AnyPublisher<(Data, URLResponse), URLError> {
        recentRequest = request

        return Future<(Data, URLResponse), URLError>() { [weak self] promise in
            guard let self = self else { return }

            switch self.result {
            case .success((let data, let code)):
                let response: URLResponse
                if self.isHttpResonse {
                    response = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
                } else {
                    response = URLResponse()
                }

                promise(.success((data, response)))
            case .failure(let error):
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
