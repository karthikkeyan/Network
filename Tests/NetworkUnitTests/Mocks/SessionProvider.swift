//
//  SessionProvider.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-18.
//

import Foundation
import Network

final class SessionProvider: URLRequestInfoProviding {
    var token: String?
    var headerKey: String?

    func addInfo(to request: URLRequest) -> URLRequest {
        guard let token = token, let key = headerKey else {
            return request
        }

        var newRequest = request
        newRequest.addValue(token, forHTTPHeaderField: key)
        return newRequest
    }
}
