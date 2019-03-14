//
//  DetailResource.swift
//  Symphony
//
//  Created by Bradley Hilton on 11/18/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

open class DetailResource<Detail : DetailType> : Resource<Detail> {
    
    init<L>(resource: ListResource<L>, detail: Detail) where L.Detail == Detail {
        super.init { return GET(resource.request()).query(nil).appendPath("/\(detail.id)") }
        resource.observe { [weak self] result in
            if var list = result.value, list.remove(detail) == nil {
                self?.result = .deleted
            }
        }
        observe(resource, method: type(of: resource).detailObserver)
    }
    
    override func makeCacheRequest() {}
    
    open func update(_ detail: Detail, failure: @escaping (Error) -> ()) {
        guard let previous = result.value else { return }
        result.setValue(detail)
        PATCH<Detail>(request()).body(detail).failure { (error, request) in
            self.result.setValue(previous)
            failure(error)
        }.begin()
    }
    
}
