//
//  CustomUI.swift
//  ProjetosI
//
//  Created by Isaías Lima on 18/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        willSet(radius) {
            self.layer.cornerRadius = radius
        }
    }
}

@IBDesignable
class RoundImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        willSet(radius) {
            self.layer.cornerRadius = radius
        }
    }
}

@IBDesignable
class RoundTextField: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        willSet(radius) {
            self.layer.cornerRadius = radius
        }
    }

    @IBInspectable var placeholderColor: UIColor = UIColor.white {
        willSet(color) {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor : color])
        }
    }

    var isValidDate: Bool {

        let text = self.text ?? ""
        if text.characters.count > 10 {
            return false
        }

        let regex = "([0-9]{4})\\/([0-9]{2})\\/([0-9]{2})\\b" /*"/([0-9]{4}-[0-9]{2}-[1-9]{2})*$/gs"*/
        let test = NSPredicate(format: "SELF MATCHES %@", regex)

        return test.evaluate(with: text)
    }

    var isValidGender: Bool {

        let text = self.text ?? ""
        if text == "Masculino" || text == "Feminino" {
            return true
        }
        return false
    }
}

@IBDesignable
class RoundView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        willSet(radius) {
            self.layer.cornerRadius = radius
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        willSet(color) {
            self.layer.borderColor = color.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        willSet(width) {
            self.layer.borderWidth = width
        }
    }
}
