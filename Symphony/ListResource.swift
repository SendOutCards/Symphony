//
//  ListResource.swift
//  Pods
//
//  Created by Bradley Hilton on 8/4/16.
//
//

struct Weak<T : AnyObject> {
    weak var value: T?
}

public protocol ListType : Collection, DataConvertible {
    associatedtype Detail
    mutating func insert(_ element: Detail)
    @discardableResult
    mutating func remove(_ element: Detail) -> Detail?
}

open class ListResource<List : ListType> : ArchivedResource<List> where List.Detail : DetailType {
    
    public override init(archiveKey: String, bundle: Bundle = .main, request: @escaping () -> GET<List>) {
        super.init(archiveKey: archiveKey, bundle: bundle, request: request)
    }
    
    open func create(_ detail: List.Detail, success: @escaping (List.Detail) -> (), failure: @escaping (Error) -> ()) {
        request().POST(List.Detail.self).body(detail).query(nil).success(201) { response in
            success(response.body)
            self.insert(response.body)
        }.failure { error, request in
            failure(error)
        }.begin()
    }
    
    func insert(_ detail: List.Detail) {
        guard var list = result.value else { return }
        list.insert(detail)
        result.setValue(list)
    }
    
    open func delete(_ detail: List.Detail, failure: @escaping (Error) -> ()) {
        guard var list = result.value else { return }
        list.remove(detail)
        result.setValue(list)
        DELETE<List.Detail>(request()).query(nil).appendPath("/\(detail.id)").failure { (error, request) in
            self.insert(detail)
            failure(error)
        }.begin()
    }
    
    override func networkSuccess(_ response: Response<List>) {
        super.networkSuccess(response)
        for detailResource in detailResources.values.compactMap({ $0.value }) {
            detailResource.result = .loading
            detailResource.refresh()
        }
    }
    
    var detailResources: [List.Detail : Weak<DetailResource<List.Detail>>] = [:]
    
    open func resourceForDetail(_ detail: List.Detail) -> DetailResource<List.Detail> {
        guard let detailResource = detailResources[detail]?.value else {
            let detailResource = DetailResource(resource: self, detail: detail)
            detailResources[detail] = Weak(value: detailResource)
            return detailResource
        }
        return detailResource
    }
    
    func detailObserver(_ result: Result<List.Detail>) {
        guard case .refreshed(let detail) = result else { return }
        insert(detail)
    }
    
}


