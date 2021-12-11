//
//  NetworkRequesting.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

public protocol NetworkRequesting {
    func send(request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError>
}
