//
//  NetworkService.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

final class NetworkService: NetworkRequesting {
    let requestReceiver: NetworkRequestReceiving

    init(requestReceiver: NetworkRequestReceiving) {
        self.requestReceiver = requestReceiver
    }

    func send(request: URLRequest) -> AnyPublisher<NetworkResponse, NetworkError> {
        requestReceiver
            .receive(request: request)
    }
}
