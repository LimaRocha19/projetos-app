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
//            self.onLabel.text = "\(d.onDelay) s"
//            self.offLabel.text = "\(d.offDelay) s"

            var index: Int = 0
            if d.onDelay != self.onTimes[self.onSelected /* self.onDelayPV.selectedRow(inComponent: 0) */] {
                index = self.onTimes.index(of: d.onDelay) ?? 0
                self.onDelayPV.selectRow(index, inComponent: 0, animated: true)
                self.onSelected = index
            }
            if d.offDelay/60 != self.offTimes[self.offSelected /*self.offDelayPV.selectedRow(inComponent: 0) */] {
                index = self.offTimes.index(of: d.offDelay/60) ?? 0
                self.offDelayPV.selectRow(index, inComponent: 0, animated: true)
                self.offSelected = index
            }

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
//    @IBOutlet weak var onLabel: UILabel!
//    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var _switch: UISwitch!
    @IBOutlet weak var onDelayPV: UIPickerView!
    @IBOutlet weak var offDelayPV: UIPickerView!
    
    fileprivate var manager: SocketManager!
    fileprivate var socket: SocketIOClient!
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    fileprivate let onTimes: [Double] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    fileprivate let offTimes: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

    fileprivate var onSelected: Int = 0
    fileprivate var offSelected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UIBarButtonItem(customView: self.spinner)
        self.spinner.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItems = [item]

        self.onDelayPV.delegate = self
        self.onDelayPV.dataSource = self
        self.offDelayPV.delegate = self
        self.offDelayPV.dataSource = self

        self.manager = SocketManager(socketURL: URL(string: "https://projetos-eletronicos.herokuapp.com/")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket

        self._switch.isUserInteractionEnabled = false
        self.onDelayPV.isUserInteractionEnabled = false
        self.offDelayPV.isUserInteractionEnabled = false
        self.socket.connect()

        self.socket.on(clientEvent: .connect) { (data, ack) in
            self.spinner.startAnimating()
            self.socket.emit("consult", with: [self.data])
        }

        self.socket.on("device") { (dev, ack) in
            self.spinner.stopAnimating()
            self._switch.isUserInteractionEnabled = true
            self.onDelayPV.isUserInteractionEnabled = true
            self.offDelayPV.isUserInteractionEnabled = true
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

extension DeviceVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.onDelayPV:
            return self.onTimes.count
        case self.offDelayPV:
            return self.offTimes.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.onDelayPV:
            return "\(self.onTimes[row])"
        case self.offDelayPV:
            return "\(self.offTimes[row])"
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.onDelayPV:
            self.spinner.startAnimating()
            ServerManager.message(topic: self.data["device_id"] ?? "fake", key: "onDelay", value: "\(self.onTimes[row])", fake: false) { (status) in
                switch status {
                case .success(let dev):
                    self.onSelected = row
                    print(#function, dev)
                case .failure(let error):
                    print(#function, error.localizedDescription)
                }
            }
        case self.offDelayPV:
            ServerManager.message(topic: self.data["device_id"] ?? "fake", key: "offDelay", value: "\(self.offTimes[row]*60)", fake: false) { (status) in
                switch status {
                case .success(let dev):
                    self.offSelected = row
                    print(#function, dev)
                case .failure(let error):
                    print(#function, error.localizedDescription)
                }
            }
        default:
            print(#function)
        }
    }

}
