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
    private let eventSteam: NetworkEventStream

    init(platform: NetworkPlatform, infoProviders: [URLRequestInfoProviding], eventSteam: NetworkEventStream) {
        self.platform = platform
        self.infoProviders = infoProviders
        self.eventSteam = eventSteam
    }

    func send(request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
        var finalRequest = request
        for infoProvider in infoProviders {
            finalRequest = infoProvider.addInfo(to: finalRequest)
        }

        eventSteam.publish(event: .request(finalRequest))

        return platform
            .executeRequest(finalRequest)
            .tryMap { [weak self] (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError(error: URLError(.badServerResponse), statusCode: NetworkError.unexpectedServerErrorCode)
                }

                let successStatusCode = 200
                if httpResponse.statusCode == successStatusCode {
                    let response = NetworkResponse(payload: data)
                    self?.eventSteam.publish(event: .response(response))
                    return response
                }

                throw NetworkError(error: URLError(.badServerResponse), statusCode: httpResponse.statusCode)
            }.mapError { [weak self] in
                let networkError: NetworkError
                if let existingError = $0 as? NetworkError {
                    networkError = existingError
                } else {
                    networkError = NetworkError(error: $0, statusCode: NetworkError.localErrorCode)
                }

                self?.eventSteam.publish(event: .error(networkError))
                return networkError
            }.eraseToAnyPublisher()
    }
}
