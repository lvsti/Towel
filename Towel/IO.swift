//
//  IO.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 05. 11..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

protocol FolderIO {
    func urlsForDirectory(directory: NSSearchPathDirectory, inDomains domainMask: NSSearchPathDomainMask) -> [NSURL]
    func itemExistsAtURL(url: NSURL) -> Bool
    func removeItemAtURL(url: NSURL) throws
    func sizeOfItemAtURL(url: NSURL) throws -> UInt64
}

extension NSFileManager: FolderIO {
    func urlsForDirectory(directory: NSSearchPathDirectory, inDomains domainMask: NSSearchPathDomainMask) -> [NSURL] {
        return URLsForDirectory(directory, inDomains: domainMask)
    }
    
    func sizeOfItemAtURL(url: NSURL) throws -> UInt64 {
        guard let path = url.path else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
        }
        return (try attributesOfItemAtPath(path)[NSFileSize] as? NSNumber)!.unsignedLongLongValue
    }
    
    func itemExistsAtURL(url: NSURL) -> Bool {
        guard let path = url.path else {
            return false
        }
        return fileExistsAtPath(path)
    }
}


protocol FileIO {
    func dataWithContentsOfURL(url: NSURL) -> NSData?
    func writeData(data: NSData, toURL url: NSURL, options: NSDataWritingOptions) throws
}

extension NSFileManager: FileIO {
    func dataWithContentsOfURL(url: NSURL) -> NSData? {
        return NSData(contentsOfURL: url)
    }
    
    func writeData(data: NSData, toURL url: NSURL, options: NSDataWritingOptions) throws {
        try data.writeToURL(url, options: options)
    }    
}
