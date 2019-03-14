//
//  Archiver.swift
//  ConvertibleArchiver
//
//  Created by Bradley Hilton on 4/12/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

import Convertible

enum Error : Swift.Error {
    case bundleResourceNotFound(key: String)
}

public struct NilLiteral : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {}
}

public enum Archiver {
    
    public static func save<T : DataSerializable>(value: T?, key: String) throws {
        guard let value = value else { try remove(key: key); return }
        try value.serializeToData().write(to: URL(fileURLWithPath: filePath(key)))
    }
    
    public static func save(value: NilLiteral, key: String) throws {
        try remove(key: key)
    }
    
    public static func remove(key: String) throws {
        try FileManager.default.removeItem(atPath: filePath(key))
    }
    
    public static func restore<T : DataInitializable>(type: T.Type = T.self, key: String, bundle: Bundle? = nil) throws -> T? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath(key)), options: [])
            return try T.initializeWithData(data)
        } catch {
            guard let bundle = bundle else { throw error }
            return try restoreFromBundle(key: key, bundle: bundle)
        }
    }
    
    private static func restoreFromBundle<T : DataInitializable>(key: String, bundle: Bundle) throws -> T? {
        guard let bundleFilePath = bundle.path(forResource: key, ofType: nil) else {
            throw Error.bundleResourceNotFound(key: key)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: bundleFilePath))
        return try T.initializeWithData(data)
    }
    
    private static func filePath(_ key: String) -> String {
        return documentDirectory + key
    }
    
    private static var documentDirectory: String {
        if let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return directoryPath + "/"
        }
        return ""
    }
    
}
