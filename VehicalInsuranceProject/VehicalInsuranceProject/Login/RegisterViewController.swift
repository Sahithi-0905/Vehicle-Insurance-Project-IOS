//
//  RegisterViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 28/11/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailfield: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassword:UITextField!
    @IBOutlet var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpCllicked(_ sender: Any) {
        guard let email = emailfield.text
        else {
            errorLabel.text = "Please enter an email."
            errorLabel.textColor = .red
            return
        }
        
        guard let password = passwordField.text
        else{
            errorLabel.text = "Please enter a password."
            errorLabel.textColor = .red
            return
        }
        if passwordField.text != confirmPassword.text {
                errorLabel.text = "Passwords do not match. Please try again."
                errorLabel.textColor = .red
                return
        }
        errorLabel.text = ""
        Auth.auth().createUser(withEmail: email, password: password) { fire, error in
            if let e = error{
                print("eror")
                self.errorLabel.text = "Sign-up failed. Please try again."
                self.errorLabel.textColor = .red
            }
            else{
                self.errorLabel.text = ""
                }
            
            self.performSegue(withIdentifier: "goToNext", sender: self)
        
        }
    }
    
}
