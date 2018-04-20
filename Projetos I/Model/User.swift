//
//  User.swift
//  Projetos I
//
//  Created by Isaías Lima on 04/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import JASON

class User: NSObject {

    var username: String
    var email: String
    var _id: String

    init(username: String, email: String, _id: String) {
        self.username = username
        self.email = email
        self._id = _id
    }

    convenience init?(json: JSON?) {
        guard let json = json
            , let username = json["username"].string
            , let email = json["email"].string
            , let _id = json["_id"].string else {
                return nil
        }

        self.init(username: username, email: email, _id: _id)
    }
}
