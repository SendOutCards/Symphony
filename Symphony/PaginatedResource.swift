//
//  PaginatedResource.swift
//  Symphony
//
//  Created by Bradley Hilton on 7/27/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

open class PaginatedResource<Model> : Resource<[Model]> {
    
    fileprivate let limit: Int
    fileprivate var resourcesCount: Int?
    
    public init(limit: Int, request: @escaping () -> GET<[Model]>) {
        self.limit = limit
        super.init(request: request)
    }
    
    fileprivate func paginatedRequest(offset: Int) -> GET<[Model]> {
        return request().cachePolicy(.reloadIgnoringLocalCacheData).appendQueryItems(["limit" : String(limit), "offset" : String(offset)])
    }
    
    open override func refresh() {
        if let value = result.value {
            result = .refreshing(value)
        } else {
            result = .loading
        }
        paginatedRequest(offset: 0).success(200) { response in
            let header = "X-Resources-Count"
            self.resourcesCount = (response.headers[header] ?? response.headers[header.lowercased()]).flatMap { Int($0) }
            self.result = .refreshed(response.body)
        }.failure { _, _ in
            guard let value = self.result.value else {
                return self.result = .failedLoad
            }
            self.result = .failedRefresh(value)
        }.begin()
    }
    
    open var loadMoreResults: ((_ completion: @escaping (_ success: Bool) -> ()) -> ())? {
        guard let results = result.value, (resourcesCount ?? Int.max) > results.count else { return nil }
        return { [weak self] completion in
            guard let resource = self else { return }
            resource.paginatedRequest(offset: results.count).success(200) { response in
                resource.result = .refreshed(results + response.body)
                completion(true)
            }.failure { _, _ in
                completion(false)
            }.begin()
        }
    }
    
}
