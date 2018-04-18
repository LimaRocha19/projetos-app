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

        self.spinner.startAnimating()
        ServerManager.devices(fake: true, cached: true) { (status) in
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
}

