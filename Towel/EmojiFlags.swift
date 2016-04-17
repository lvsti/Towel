//
//  EmojiFlags.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 17..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation

extension String {
    
    static func emojiFlagForCountryCode(code: String) -> String? {
        guard
            code.characters.count == 2 &&
            NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: code) != nil
        else {
            return nil
        }
        
        let flagPrefix = UnicodeScalar(Int(code.lowercaseString.unicodeScalars.first!.value) - 97 + 0x1F1E6)
        let flagSuffix = UnicodeScalar(Int(code.lowercaseString.unicodeScalars.last!.value) - 97 + 0x1F1E6)
        
        return "\(flagPrefix)\(flagSuffix)"
    }
    
}

