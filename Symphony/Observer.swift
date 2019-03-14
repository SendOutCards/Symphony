//
//  Observer.swift
//  Symphony
//
//  Created by Bradley Hilton on 4/13/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

protocol ObserverProtocol {
    var hasObserver: Bool { get }
    func takeAny(_ any: Any)
}

struct WeakObserver : ObserverProtocol {
    
    weak var observer: AnyObject?
    var method: (AnyObject?) -> ((Any) -> ())?
    
    init<U : AnyObject, T>(observer: U, method: @escaping (U) -> (T) -> ()) {
        self.observer = observer
        self.method = { object in
            guard let object = object as? U else { return nil }
            return { any in
                guard let any = any as? T else { return }
                method(object)(any)
            }
        }
    }
    
    var hasObserver: Bool {
        return observer != nil
    }
    
    func takeAny(_ any: Any) {
        method(observer)?(any)
    }
    
}
