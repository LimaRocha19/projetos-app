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

            self._switch.isOn = d.closed

            if d.working {
                self.activeLabel.textColor = .green
            } else {
                self.activeLabel.textColor = .red
            }
        }
    }

    var data: [String : String]!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var _switch: UISwitch!
    
    fileprivate var manager: SocketManager!
    fileprivate var socket: SocketIOClient!
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UIBarButtonItem(customView: self.spinner)
        self.spinner.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItems = [item]

        self.manager = SocketManager(socketURL: URL(string: "https://projetos-eletronicos.herokuapp.com/")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket

        self._switch.isUserInteractionEnabled = false
        self.socket.connect()

        self.socket.on(clientEvent: .connect) { (data, ack) in
            self.spinner.startAnimating()
            self.socket.emit("consult", with: [self.data])
        }

        self.socket.on("device") { (dev, ack) in
            self.spinner.stopAnimating()
            self._switch.isUserInteractionEnabled = true
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
        self.spinner.startAnimating()
        self._switch.isUserInteractionEnabled = false
        ServerManager.message(topic: self.data["device_id"] ?? "fake", key: "closed", value: "\(!(Bool(self.closedLabel.text!)!))") { (status) in
//            self._switch.isUserInteractionEnabled = true
            switch status {
            case .success(let dev):
                print(#function, dev)
//                self.device = dev
            case .failure(let error):
                self._switch.isOn = false
                print(#function, error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 6 {
            let controller = UIAlertController(title: "Deletando Dispositivo", message: "Tem certeza de que deseja deletar este dispositivo?", preferredStyle: .actionSheet)
            let yes = UIAlertAction(title: "Sim", style: .destructive) { (action) in
                ServerManager.delete(topic: self.data["device_id"] ?? "fake", fake: false, completion: { (status) in
                    switch status {
                    case .success(let msg):
                        self.socket.disconnect()
                        print(#function, msg)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self.showAlertController(withTitle: "Err :(", andMessage: error.localizedDescription)
                    }
                })
            }
            let nop = UIAlertAction(title: "Não", style: .cancel, handler: nil)
            controller.addAction(yes)
            controller.addAction(nop)
            self.present(controller, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.socket.disconnect()
    }
}
