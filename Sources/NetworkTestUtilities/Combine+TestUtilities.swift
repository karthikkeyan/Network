//
//  Combine+TestUtilities.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-10.
//

import Foundation
import Combine

public extension Publisher {
    func start(with bag: inout Set<AnyCancellable>) {
        sink { completion in
        } receiveValue: { data in
        }.store(in: &bag)
    }
    
    func onValue(_ perform: @escaping (Output) -> Void) -> AnyPublisher<Output, Failure> {
        map {
            perform($0)
            return $0
        }.eraseToAnyPublisher()
    }

    func onError(_ perform: @escaping (Failure) -> Void) -> AnyPublisher<Output, Failure> {
        mapError {
            perform($0)
            return $0
        }.eraseToAnyPublisher()
    }
}
