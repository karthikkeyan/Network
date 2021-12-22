//
//  NetworkEventStream.swift
//  
//
//  Created by Karthikkeyan Bala Sundaram on 2021-12-21.
//

import Combine
import Foundation

struct NetworkEventStream {
    private let subject: PassthroughSubject<NetworkEvent, Never>
    let publisher: AnyPublisher<NetworkEvent, Never>
    
    init() {
        let subject = PassthroughSubject<NetworkEvent, Never>()

        self.subject = subject
        self.publisher = subject.eraseToAnyPublisher()
    }

    func publish(event: NetworkEvent) {
        subject.send(event)
    }
}
