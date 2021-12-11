//
//  NetworkError.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation

public struct NetworkError: Error {
    public static let localErrorCode = -1
    public static let unexpectedServerErrorCode = -2
    
    public let underlyingError: Error
    public let statusCode: Int

    public init(error: Error, statusCode: Int) {
        self.underlyingError = error
        self.statusCode = statusCode
    }
}
