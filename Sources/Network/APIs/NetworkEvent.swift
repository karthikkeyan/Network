//
//  NetworkEvent.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-21.
//

import Foundation

public enum NetworkEvent {
    case request(URLRequest)
    case response(NetworkResponse)
    case error(NetworkError)
}
