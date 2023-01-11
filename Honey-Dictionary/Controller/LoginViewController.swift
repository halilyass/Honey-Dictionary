//
//  LoginViewController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 6.01.2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Actions
    
    @IBAction func clickedSignIn(_ sender: UIButton) {
        
        guard let emailAdress = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: emailAdress, password: password) { dataResult, error in
            
            if let error = error {
                
                debugPrint("DEBUG: Error while signing in \(error.localizedDescription)")
            } else {
                
                self.dismiss(animated: true,completion: nil)
            }
        }
        
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        signInButton.layer.cornerRadius = 20
        
    }
    
}
