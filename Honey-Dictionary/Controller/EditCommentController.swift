//
//  EditCommentController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 10.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class EditCommentController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var textComment: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    var commentData : (selectedComment : Comment, selectedPost : Idea)!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textComment.layer.cornerRadius = 10
        updateButton.layer.cornerRadius = 20
        
        textComment.text = commentData.selectedComment.commentText!
    }
    
    //MARK: - Actions
    
    @IBAction func clickedUpdate(_ sender: Any) {
        
        guard let commentText = textComment.text, textComment.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        
        Firestore.firestore().collection(IDEAS_REF)
            .document(commentData.selectedPost.documentId)
            .collection(COMMENTS_REF)
            .document(commentData.selectedComment.documentId)
                .updateData([COMMENT_TEXT : commentText]) { error in
                
                if let error = error {
                    debugPrint("DEBUG: Error while updatig comment \(error.localizedDescription)")
                } else {
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
        }
    }
}
