//
//  DeviceVC.swift
//  ProjetosI
//
//  Created by Isaías Lima on 19/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import SocketIO
import JASON

class DeviceVC: UITableViewController {

    var device: Device! {
        willSet(d) {
            self.nameLabel.text = d.name
            self.topicLabel.text = d.topic
            self.closedLabel.text = "\(d.closed)"
            self.activeLabel.text = "\(d.working)"
            self.onLabel.text = "\(d.onDelay) s"
            self.offLabel.text = "\(d.offDelay) s"
        }
    }

    var data: [String : String]!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!

    fileprivate var manager: SocketManager!
    fileprivate var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager = SocketManager(socketURL: URL(string: "https://projetos-eletronicos.herokuapp.com/")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket

        self.socket.connect()

        self.socket.on(clientEvent: .connect) { (data, ack) in
            self.socket.emit("consult", with: [self.data])
        }

        self.socket.on("device") { (dev, ack) in
            print(#function, dev, ack)
            let json = JSON(dev[0])
            guard let d = Device(json: json) else {
                return
            }
            self.device = d
            self.socket.emit("consult", with: [self.data])
        }
    }
    
    @IBAction func open(_ sender: Any) {
        ServerManager.message(topic: self.data["device_id"] ?? "fake", key: "closed", value: "change") { (status) in
            print(#function, "sent")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.socket.disconnect()
    }
}
