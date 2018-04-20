//
//  MainVC.swift
//  ProjetosI
//
//  Created by Isaías Lima on 18/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

class MainVC: UITableViewController {

    fileprivate var devices: [Device] = []
    fileprivate var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate var topicTF: UITextField!
    fileprivate var nameTF: UITextField!

    fileprivate var selected: Device!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "device" {
            guard let controller = segue.destination as? DeviceVC else {
                return
            }
            controller.data = ["token" : ServerManager.token,
                               "user_id": ServerManager.user._id,
                               "device_id": self.selected.topic]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = ServerManager.user.username
        self.navigationItem.prompt = ServerManager.user.email

        self.spinner.hidesWhenStopped = true
        let item = UIBarButtonItem(customView: self.spinner)
        self.navigationItem.rightBarButtonItems?.append(item)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetch()
    }

    func fetch() {
        self.spinner.startAnimating()
        ServerManager.devices(fake: false, cached: true) { (status) in
            self.spinner.stopAnimating()
            switch status {
            case .success(let devices):
                self.devices = devices
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlertController(withTitle: "Error :(", andMessage: error.localizedDescription)
            }
        }
    }

    @IBAction func logout(_ sender: Any) {
        ServerManager.logoff {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateInitialViewController()
            self.present(loginViewController!, animated: true)
        }
    }

    @IBAction func add(_ sender: Any) {
        let controller = UIAlertController(title: "Novo Dispositivo", message: "Preencha os dados abaixo", preferredStyle: .alert)
        let add = UIAlertAction(title: "Adicionar", style: .default) { (action) in
            self.spinner.startAnimating()
            let topic = self.topicTF.text!
            let name = self.nameTF.text!
            ServerManager.add(topic: topic, name: name, completion: { (status) in
                self.spinner.stopAnimating()
                switch status {
                case .success(let dev):
                    print(#function, dev)
                    self.fetch()
                case .failure(let error):
                    self.showAlertController(withTitle: "Error :(", andMessage: error.localizedDescription)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        controller.addTextField { (tf) in
            tf.placeholder = "Nome"
            self.nameTF = tf
        }
        controller.addTextField { (tf) in
            tf.placeholder = "Tópico"
            self.topicTF = tf
        }
        controller.addAction(add)
        controller.addAction(cancel)

        self.present(controller, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)

        let device = self.devices[indexPath.row]
        cell.textLabel?.text = device.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected = self.devices[indexPath.row]
        self.performSegue(withIdentifier: "device", sender: self)
    }
}

