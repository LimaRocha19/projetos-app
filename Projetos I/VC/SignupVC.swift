//
//  SignupVC.swift
//  ProjetosI
//
//  Created by Isaías Lima on 18/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

class SignupVC: UITableViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    fileprivate var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameTF.delegate = self
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func signup(_ sender: Any) {
        self.enter()
    }

    func enter() {

        if self.usernameTF.text! == "" || self.emailTF.text! == "" || self.passwordTF.text! == "" {
            self.showAlertController(withTitle: "Erro :(", andMessage: "Preencha todos os campos para poder prosseguir com o cadastro!")
            return
        }

        self.spinner.startAnimating()

        ServerManager.signup(params: ["username" : self.usernameTF.text!, "email" : self.emailTF.text!, "password" : self.passwordTF.text!], fake: true) { (status) in
            self.spinner.stopAnimating()

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
}

extension SignupVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTF {
            self.emailTF.becomeFirstResponder()
            return false
        } else if textField == self.emailTF {
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
