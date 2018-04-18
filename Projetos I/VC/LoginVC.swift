//
//  LoginVC.swift
//  ProjetosI
//
//  Created by Isaías Lima on 18/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

class LoginVC: UITableViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    fileprivate var user: User!
    fileprivate var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameTF.delegate = self
        self.passwordTF.delegate = self

        if ServerManager.isLogged {
            self.logged()
        }
    }

    @IBAction func access(_ sender: Any) {
        self.login()
    }

    @IBAction func password(_ sender: Any) {

        let send = UIAlertAction(title: "Enviar", style: .default) { (action) in
            self.spinner.startAnimating()
            ServerManager.forgot(email: self.textField.text!, fake: true, completion: { (status) in
                self.spinner.stopAnimating()
                switch status {
                case .success(let msg):
                    self.showAlertController(withTitle: "Eba :D", andMessage: msg)
                case .failure(let error):
                    self.showAlertController(withTitle: "Não :(", andMessage: error.localizedDescription)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) in
            self.spinner.stopAnimating()
        }

        let controller = UIAlertController(title: "Esqueceu sua senha?", message: "Coloque seu endereço de e-mail cadastrado para enviarmos sua recuperação de senha", preferredStyle: .alert)
        controller.addTextField { (field) in
            self.textField = field
        }
        controller.addAction(send)
        controller.addAction(cancel)

        self.present(controller, animated: true, completion: nil)
    }

    func login() {
        if self.usernameTF.text! == "" || self.passwordTF.text! == "" {
            self.showAlertController(withTitle: "Error :(", andMessage: "Preencha os dados corretamente!")
            return
        }

        self.spinner.startAnimating()
        ServerManager.signin(params: ["username" : self.usernameTF.text!, "password" : self.passwordTF.text!], fake: true) { (status) in
            switch status {
            case .success(let user):
                ServerManager.user = user
                print(#function, user)
                self.performSegue(withIdentifier: "login", sender: self)
            case .failure(let error):
                self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
            }
        }
    }

    func logged() {
        self.spinner.startAnimating()
        ServerManager.profile(fake: true) { (status) in
            switch status {
            case .success(let user):
                print(#function, user)
                self.performSegue(withIdentifier: "login", sender: self)
            case.failure(let error):
                self.showAlertController(withTitle: "Err :(", andMessage: error.localizedDescription)
            }
        }
    }
}

extension LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTF {
            self.passwordTF.becomeFirstResponder()
            return false
        } else if textField == self.passwordTF {
            textField.resignFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            return true
        }
    }

}

extension UIViewController {
    func showAlertController(withTitle title: String, andMessage message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Entendido", style: .cancel, handler: nil)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }

    func showAlertController(withTitle title: String, andMessage message: String, andActions actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            controller.addAction(action)
        }
        self.present(controller, animated: true, completion: nil)
    }
}
