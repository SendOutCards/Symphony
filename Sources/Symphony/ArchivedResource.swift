//
//  ArchivedResource.swift
//  Symphony
//
//  Created by Bradley Hilton on 7/27/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

import Foundation
import August
import Convertible
import ConvertibleArchiver

private let archiveQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.qualityOfService = .utility
    return queue
}()

open class ArchivedResource<Model : DataConvertible> : Resource<Model> {
    
    let archiveKey: String
    let bundle: Bundle
    
    public init(archiveKey: String, bundle: Bundle = .main, request: @escaping () -> GET<Model>) {
        self.archiveKey = archiveKey
        self.bundle = bundle
        super.init(request: request)
        observe(self, method: type(of: self).observe)
    }
    
    func observe(_ result: Result<Model>) {
        switch result {
        case .refreshed(let value):
            archiveQueue.addOperation {
                try? Archiver.save(value: value, key: self.archiveKey)
            }
        case .unloaded:
            try? Archiver.remove(key: self.archiveKey)
        default: break
        }
    }
    
    override func makeCacheRequest() {
        archiveQueue.addOperation {
            do {
                if let value = try Archiver.restore(type: Model.self, key: self.archiveKey, bundle: self.bundle) {
                    OperationQueue.main.addOperation {
                        if self.result.flag == .loading {
                            self.result = .loadedCache(value)
                        } else if self.result.flag == .failedLoad {
                            self.result = .failedRefresh(value)
                        }
                    }
                }
            } catch {}
        }
    }
    
}
