//
//  DetailType.swift
//  Symphony
//
//  Created by Bradley Hilton on 11/18/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

public protocol DetailType : DataConvertible, Hashable {
    var id: Int { get }
}

extension DetailType {
    
    public var hashValue: Int {
        return id
    }
    
}

public func ==<T : DetailType>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}
