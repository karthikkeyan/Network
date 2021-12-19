//
//  DeviceInfoProvider.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-18.
//

import Foundation
import Network

final class DeviceInfoProvider: URLRequestInfoProviding {
    var deviceType: String?
    var headerKey: String?

    func addInfo(to request: URLRequest) -> URLRequest {
        guard let deviceType = deviceType, let key = headerKey else {
            return request
        }

        var newRequest = request
        newRequest.addValue(deviceType, forHTTPHeaderField: key)
        return newRequest
    }
}
