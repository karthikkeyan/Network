//
//  NetworkServiceBuilder.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation

public struct NetworkServiceBuilder {
    private let platform: NetworkPlatform

    public init(platform: NetworkPlatform) {
        self.platform = platform
    }

    public func build() -> NetworkRequesting {
        NetworkService(platform: platform)
    }
}
