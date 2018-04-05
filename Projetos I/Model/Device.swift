//
//  Device.swift
//  Projetos I
//
//  Created by Isaías Lima on 04/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import JASON

class Device: NSObject {

    var name: String
    var topic: String
    var closed: Bool
    var working: Bool
    var onDelay: Double
    var offDelay: Double

    init(name: String, topic: String, closed: Bool, working: Bool, onDelay: Double, offDelay: Double) {
        super.init()
        self.name = name
        self.topic = topic
        self.closed = closed
        self.working = working
        self.onDelay = onDelay
        self.offDelay = offDelay
    }

    convenience init?(json: JSON) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let json = json
            , let name = json["name"].string
            , let topic = json["topic"].string
            , let closed = json["closed"].string
            , let lastUpdated = json["last_updated"].string
            , let onDelay = json["onDelay"].double
            , let offDelay = json["offDelay"].double
            , let lastUpdt = formatter.date(from: lastUpdated) else {
                return nil
        }

        var working = true

        if (Date().timeIntervalSince1970 - lastUpdt.timeIntervalSince1970) >= 30 {
            working = false
        }

        self.init(name: name, topic: topic, closed: closed, working: working, onDelay: onDelay, offDelay: offDelay)
    }
}
