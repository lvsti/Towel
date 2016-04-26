//
//  DBUser.swift
//  Towel
//
//  Created by Tamas Lustyik on 2016. 04. 26..
//  Copyright © 2016. Tamas Lustyik. All rights reserved.
//

import Foundation
import RealmSwift

class DBUser: Object {
    dynamic var _userID: Int32 = 0
    dynamic var _username: String?
}

extension DBUser: User {
    var userID: Int32 { return _userID }
    var username: String { return _username! }
}
