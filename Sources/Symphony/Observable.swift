//
//  Observable.swift
//  Symphony
//
//  Created by Bradley Hilton on 8/15/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

open class Observable<Value> {
    
    open var value: Value {
        didSet {
            notifyObservers()
        }
    }
    
    fileprivate typealias Observer = (Value) -> ()
    fileprivate var observers = [Observer]()
    fileprivate var weakObservers = [WeakObserver]()
    
    public init(value: Value) {
        self.value = value
    }
    
    open func observe(_ observer: @escaping (Value) -> ()) {
        observers.append(observer)
        observer(value)
    }
    
    open func observe<Observer : AnyObject>(_ observer: Observer, method: @escaping (Observer) -> (Value) -> ()) {
        weakObservers.append(WeakObserver(observer: observer, method: method))
        method(observer)(value)
    }
    
    func notifyObservers() {
        observers.forEach { $0(self.value) }
        weakObservers = weakObservers.filter { weakObserver in
            guard weakObserver.hasObserver else { return false }
            weakObserver.takeAny(self.value)
            return true
        }
    }
    
}
