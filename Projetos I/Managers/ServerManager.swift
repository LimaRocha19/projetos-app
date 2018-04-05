//
//  ServerManager.swift
//  ProjetosI
//
//  Created by Isaías Lima on 04/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import JASON

enum RequestStatus<T> {
    case success(T)
    case failure(Error)
}

class ServerManager {

    static var cache: [String : Any] = [:]

    private struct API {

        typealias DyURL = (String) -> String

        private init() {}

        static let base             = "https://projetos-eletronicos.herokuapp.com"
        static let user: DyURL    = { return "\(base)user/\($0)/" }
        static let web: DyURL     = { return "\(base)web/\($0)/" }
        static let place: DyURL   = { return "\(base)place/\($0)/" }
        static let log: DyURL     = { return "\(base)log/\($0)/" }
        static let banner: DyURL     = { return "\(base)banner/\($0)/" }
    }

}
