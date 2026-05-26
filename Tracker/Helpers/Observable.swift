//
//  Observable.swift
//  Tracker
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import Foundation

class Observable<T> {
    var value: T {
        didSet {
            listeners.forEach { $0(value) }
        }
    }
    
    private var listeners: [(T) -> Void] = []
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T) -> Void) {
        listeners.append(listener)
        listener(value)
    }
}
