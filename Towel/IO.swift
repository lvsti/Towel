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
    func removeItemAtURL(url: NSURL) throws
}

extension NSFileManager: FolderIO {
    func urlsForDirectory(directory: NSSearchPathDirectory, inDomains domainMask: NSSearchPathDomainMask) -> [NSURL] {
        return URLsForDirectory(directory, inDomains: domainMask)
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
