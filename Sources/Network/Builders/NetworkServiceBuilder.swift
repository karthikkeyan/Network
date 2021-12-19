//
//  NetworkServiceBuilder.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation

public struct NetworkServiceBuilder {
    private let platform: NetworkPlatform
    private let infoProviders: [URLRequestInfoProviding]

    public init(platform: NetworkPlatform, infoProviders: [URLRequestInfoProviding]) {
        self.platform = platform
        self.infoProviders = infoProviders
    }

    public func build() -> NetworkRequesting {
        NetworkService(platform: platform, infoProviders: infoProviders)
    }
}
