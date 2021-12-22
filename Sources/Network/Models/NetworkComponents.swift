//
//  NetworkComponents.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-21.
//

import Combine
import Foundation

public struct NetworkComponents {
    public let service: NetworkRequesting
    public let eventPublisher: AnyPublisher<NetworkEvent, Never>
}
