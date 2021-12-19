//
//  URLRequestInfoProviding.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-18.
//

import Foundation

public protocol URLRequestInfoProviding {
    func addInfo(to request: URLRequest) -> URLRequest
}
