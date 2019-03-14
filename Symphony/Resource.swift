//
//  Resource.swift
//  Symphony
//
//  Created by Bradley Hilton on 6/23/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

public protocol AnyResource : class {
    var status: ResultFlag { get }
    func refresh()
    func refreshIfNeeded()
    func unload()
}

open class Resource<Model : DataConvertible> : Observable<Result<Model>>, AnyResource {
    
    open let request: () -> GET<Model>
    
    open var result: Result<Model> {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    open var status: ResultFlag {
        return result.flag
    }
    
    public init(request: @escaping () -> GET<Model>) {
        self.request = request
        super.init(value: .unloaded)
    }
    
    open func refresh() {
        if let value = result.value {
            result = .refreshing(value)
            makeNetworkRequest()
        } else {
            result = .loading
            makeCacheRequest()
            makeNetworkRequest()
        }
    }
    
    open func refreshIfNeeded() {
        if result.flag != .refreshed {
            refresh()
        }
    }
    
    open func unload() {
        result = .unloaded
    }
    
    func makeCacheRequest() {
        request().cachePolicy(.returnCacheDataDontLoad).success(callback: cacheSuccess).begin()
    }
    
    func cacheSuccess(_ response: Response<Model>) {
        if result.flag == .loading {
            result = .loadedCache(response.body)
        } else if result.flag == .failedLoad {
            result = .failedRefresh(response.body)
        }
    }
    
    func makeNetworkRequest() {
        request().cachePolicy(.reloadIgnoringLocalCacheData).success(callback: networkSuccess).failure(callback: networkFailure).begin()
    }
    
    func networkSuccess(_ response: Response<Model>) {
        result = .refreshed(response.body)
    }
    
    func networkFailure(_ error: Error, request: Request) {
        if let error = error as? ResponseError, error.response.statusCode == 404 {
            return result = .deleted
        }
        guard let value = result.value else {
            return result = .failedLoad
        }
        result = .failedRefresh(value)
    }
    
}
