//
//  objectsModel.swift
//  Symphony
//
//  Created by Bradley Hilton on 4/14/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

public enum Result<Value> {
    
    case deleted
    case unloaded
    case loading
    case failedLoad
    case loadedCache(Value)
    case refreshed(Value)
    case refreshing(Value)
    case failedRefresh(Value)
    
    public internal(set) var value: Value? {
        get {
            switch self {
            case .loadedCache(let value): return value
            case .refreshed(let value): return value
            case .refreshing(let value): return value
            case .failedRefresh(let value): return value
            default: return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            switch self {
            case .loadedCache: self = .loadedCache(newValue)
            case .refreshed: self = .refreshed(newValue)
            case .refreshing: self = .refreshing(newValue)
            case .failedRefresh: self = .failedRefresh(newValue)
            default: break
            }
        }
    }
    
    internal mutating func setValue(_ value: Any) {
        if let value = value as? Value {
            self.value = value
        }
    }
    
    public var isEmpty: Bool {
        return value == nil
    }
    
    public var isLoading: Bool {
        switch self {
        case .loading, .loadedCache: return true
        default: return false
        }
    }
    
    public var flag: ResultFlag {
        switch self {
        case .deleted: return .deleted
        case .unloaded: return .unloaded
        case .loading: return .loading
        case .failedLoad: return .failedLoad
        case .loadedCache: return .loadedCache
        case .refreshed: return .refreshed
        case .refreshing: return .refreshing
        case .failedRefresh: return .failedRefresh
        }
    }
    
}

public enum ResultFlag {
    case deleted
    case unloaded
    case loading
    case failedLoad
    case loadedCache
    case refreshed
    case refreshing
    case failedRefresh
}

public protocol StaticLoadable {
    static func load()
}
