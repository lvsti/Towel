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
        guard code.characters.count == 2 else {
            return nil
        }
        
        let alphabetRange = 97...122
        guard
            let firstValue = code.unicodeScalars.first?.value,
            let lastValue = code.unicodeScalars.last?.value
        where
            alphabetRange.contains(Int(firstValue)) &&
            alphabetRange.contains(Int(lastValue))
        else {
            return nil
        }

        let flagPrefix = UnicodeScalar(Int(firstValue) - 97 + 0x1F1E6)
        let flagSuffix = UnicodeScalar(Int(lastValue) - 97 + 0x1F1E6)
        
        return "\(flagPrefix)\(flagSuffix)"
    }
    
}

