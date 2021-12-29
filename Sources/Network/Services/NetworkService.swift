//
//  NetworkService.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine
import CombineUtilities

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
        let finalRequest = requestWithInfoAdded(for: request)
        eventSteam.publish(event: .request(finalRequest))

        return platform
            .executeRequest(finalRequest)
            .tryMap(NetworkService.tryMap)
            .mapError(NetworkService.mapError)
            .publishEvent(to: eventSteam)
            .eraseToAnyPublisher()
    }

    func upload(file: URL, with request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
        let finalRequest = requestWithInfoAdded(for: request)
        eventSteam.publish(event: .request(finalRequest))

        return platform
            .executeUpload(file, with: request)
            .tryMap(NetworkService.tryMap)
            .mapError(NetworkService.mapError)
            .publishEvent(to: eventSteam)
            .eraseToAnyPublisher()
    }
    
    // MARK: Private Methods
    
    private func requestWithInfoAdded(for request: URLRequest) -> URLRequest {
        var finalRequest = request
        for infoProvider in infoProviders {
            finalRequest = infoProvider.addInfo(to: finalRequest)
        }
        return finalRequest
    }
    
    // MARK: Private Static Methods
    
    static private func tryMap(_ input: (Data?, URLResponse?)) throws -> NetworkResponse {
        guard let httpResponse = input.1 as? HTTPURLResponse else {
            throw NetworkError(error: URLError(.badServerResponse), statusCode: NetworkError.unexpectedServerErrorCode)
        }

        let successStatusCode = 200
        if httpResponse.statusCode == successStatusCode {
            let response = NetworkResponse(payload: input.0)
            return response
        }

        throw NetworkError(error: URLError(.badServerResponse), statusCode: httpResponse.statusCode)
    }

    static private func mapError(_ input: Error) -> NetworkError {
        let networkError: NetworkError
        if let existingError = input as? NetworkError {
            networkError = existingError
        } else {
            networkError = NetworkError(error: input, statusCode: NetworkError.localErrorCode)
        }
        return networkError
    }
}

// MARK: - Combine Utilities

private extension Publisher where Output == NetworkResponse, Failure == NetworkError {
    func publishEvent(to stream: NetworkEventStream) -> AnyPublisher<Output, Failure> {
        onValue {
            stream.publish(event: .response($0))
        }.onError {
            stream.publish(event: .error($0))
        }
    }
}
