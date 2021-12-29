//
//  NetworkResponse.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation

public struct NetworkResponse {
    public let payload: Data?
    
    public init(payload: Data?) {
        self.payload = payload
    }
}
