//
//  NetworkPlatform.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

public protocol NetworkPlatform {
    func performRequest(for request: URLRequest) -> AnyPublisher<(Data, URLResponse), URLError>
}

extension URLSession: NetworkPlatform {
    public func performRequest(for request: URLRequest) -> AnyPublisher<(Data, URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .eraseToAnyPublisher()
    }
}
