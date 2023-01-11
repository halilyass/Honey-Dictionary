//
//  AddController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 5.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AddController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var ideaText: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    let placeHolderText = "Idea..."
    
    var selectedCategory = Categories.Funny.rawValue
    
    var userName : String = "Misafir"
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Actions
    
    @IBAction func clickedSegment(_ sender: Any) {
        
        switch segmentCategory.selectedSegmentIndex {
            
        case 0 :
            selectedCategory = Categories.Funny.rawValue
        case 1 :
            selectedCategory = Categories.Absurd.rawValue
        case 2 :
            selectedCategory = Categories.Agenda.rawValue
        default :
            selectedCategory = Categories.Funny.rawValue
        }
        
    }
    
    @IBAction func clickedShareButton(_ sender: Any) {
        
        guard ideaText.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        
        Firestore.firestore().collection(IDEAS_REF).addDocument(data: [
            
            CATEGORY : selectedCategory,
            LIKE_NUMBER : 0,
            COMMENT_NUMBER : 0,
            IDEAS_TEXT : ideaText.text!,
            UPLOAD_DATE : FieldValue.serverTimestamp(),
            USER_NAME : userName,
            USER_ID : Auth.auth().currentUser?.uid ?? ""
            
        ]) { error in
            
            if let error = error {
                print("DEBUG: Document Error : \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        
        shareButton.layer.cornerRadius = 10
        ideaText.layer.cornerRadius = 10
        
        ideaText.text = placeHolderText
        ideaText.textColor = .lightGray
        
        ideaText.delegate = self
        
        userNameField.isEnabled = false
        
        if let name = Auth.auth().currentUser?.displayName {
            userName = name
            userNameField.text = userName
        }
        
    }
}

//MARK: - UITextViewDelegate

extension AddController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == placeHolderText {
            
            textView.text = ""
            textView.textColor = .darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            ideaText.text = placeHolderText
            ideaText.textColor = .lightGray
            
        }
        
    }
}
