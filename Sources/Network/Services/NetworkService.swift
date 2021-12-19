//
//  NetworkService.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

final class NetworkService: NetworkRequesting {
    private let platform: NetworkPlatform
    private let infoProviders: [URLRequestInfoProviding]

    init(platform: NetworkPlatform, infoProviders: [URLRequestInfoProviding]) {
        self.platform = platform
        self.infoProviders = infoProviders
    }

    func send(request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
        var finalRequest = request
        for infoProvider in infoProviders {
            finalRequest = infoProvider.addInfo(to: finalRequest)
        }

        return platform
            .executeRequest(finalRequest)
            .tryMap { (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError(error: URLError(.badServerResponse), statusCode: NetworkError.unexpectedServerErrorCode)
                }

                let successStatusCode = 200
                if httpResponse.statusCode == successStatusCode {
                    return NetworkResponse(payload: data)
                }

                throw NetworkError(error: URLError(.badServerResponse), statusCode: httpResponse.statusCode)
            }.mapError {
                if let networkError = $0 as? NetworkError {
                    return networkError
                }

                return NetworkError(error: $0, statusCode: NetworkError.localErrorCode)
            }.eraseToAnyPublisher()
    }
}
