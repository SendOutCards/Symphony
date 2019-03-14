//
//  ArchiveInfo.swift
//  Symphony
//
//  Created by Bradley Hilton on 11/18/16.
//  Copyright © 2016 Brad Hilton. All rights reserved.
//

public protocol ArchiveInfo {
    static var bundle: Bundle { get }
    static var archiveKey: String { get }
}

extension ArchiveInfo {
    
    public static var bundle: Bundle {
        return Bundle.main
    }
    
    public static var archiveKey: String {
        return "\(self)Archive"
    }
    
}
