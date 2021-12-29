//
//  NetworkPlatform.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

public protocol NetworkPlatform {
    func executeRequest(_ request: URLRequest) -> AnyPublisher<(Data, URLResponse), URLError>
    
    func executeUpload(_ file: URL, with request: URLRequest) -> AnyPublisher<(Data?, URLResponse?), Error>
}

extension URLSession: NetworkPlatform {
    public func executeRequest(_ request: URLRequest) -> AnyPublisher<(Data, URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .eraseToAnyPublisher()
    }

    public func executeUpload(_ file: URL, with request: URLRequest) -> AnyPublisher<(Data?, URLResponse?), Error> {
        Future<(Data?, URLResponse?), Error> { [weak self] promise in
            var task: URLSessionUploadTask?
            task = self?.uploadTask(with: request, fromFile: file) { (data, response, error) in
                defer { task = nil }
                if let error = error {
                    promise(.failure(error))
                    return
                }

                promise(.success((data, response)))
            }
            task?.resume()
        }
        .share()
        .eraseToAnyPublisher()
    }
}
