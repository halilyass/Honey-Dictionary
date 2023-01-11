//
//  SignUpController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 6.01.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    //MARK: - Actions
    
    @IBAction func clickedSignUp(_ sender: Any) {
        
        guard let emailAdress = emailText.text else { return }
        guard let password = passwordText.text else { return }
        guard let username = usernameText.text else { return }
        
        Auth.auth().createUser(withEmail: emailAdress, password: password) { result, error in
            
            if let error = error {
                
                debugPrint("DEBUG: User could not be created \(error.localizedDescription)")
                
            }
            //User could be create
            
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { error in
                    
                if let error = error {
                        
                    debugPrint("DEBUG: Username could not be update")
                }
            })
            
            guard let userId = result?.user.uid else { return }
            
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USERNAME : username,
                USER_CREATION_DATE : FieldValue.serverTimestamp()
            ]) { error in
                
                if let error = error {
                    
                    debugPrint("DEBUG: Error occurred while creating user \(error.localizedDescription)")
                } else {
                    
                    self.dismiss(animated: true,completion: nil)
                    
                }
            }
        }
    }
        
   
    @IBAction func clickedSignIn(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
    
    
    //MARK: - Helpers
    
    func configureUI() {
        
        emailText.layer.cornerRadius = 10
        passwordText.layer.cornerRadius = 10
        usernameText.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 20
        
    }
    
    
}
