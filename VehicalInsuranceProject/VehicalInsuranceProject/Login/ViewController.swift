//
//  ViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 27/11/24.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet var signIn: UIButton!
    @IBOutlet var sigUp: UIButton!
    @IBOutlet var labelSignup: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func signInClicked(_ sender: Any) {
        guard let email = emailTextField.text else{ return }
        guard let password = passwordTextField.text else{ return }
        
        Auth.auth().signIn(withEmail: email, password: password) { fire, error in
            if let e = error{
                print("eror")
            }
            else{
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
        }
    }

}

