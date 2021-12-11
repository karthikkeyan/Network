//
//  NetworkRequestReceiving.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

public protocol NetworkRequestReceiving {
    func receive(request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError>
}
