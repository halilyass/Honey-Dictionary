//
//  CommentController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 9.01.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class CommentController: UIViewController {
    
    //MARK: - Properties
    
    var selectedIdea : Idea!
    var comments = [Comment]()
    var ref : DocumentReference!
    let fireStore = Firestore.firestore()
    var username : String!
    var commentsListener : ListenerRegistration!
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var writeComment: UITextField!
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        ref = fireStore.collection(IDEAS_REF).document(selectedIdea.documentId)
        
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        
        self.view.keyboardConfigure()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        listener()
    }
    
    //MARK: - Actions
    
    @IBAction func clickedPlus(_ sender: Any) {
        
        guard let commentText = writeComment.text, writeComment.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else { return }
        
        fireStore.runTransaction { (transaction, errorPointer) -> Any? in
            
            let selectedIdea : DocumentSnapshot
            do {
                
                try selectedIdea = transaction.getDocument(self.fireStore.collection(IDEAS_REF).document(self.selectedIdea.documentId))
                
            } catch let error as NSError {
                
                debugPrint("DEBUG: \(error.localizedDescription)")
                return nil
            }
            
            guard let commentNumber = (selectedIdea.data()?[COMMENT_NUMBER] as? Int) else { return nil}
            
            transaction.updateData([COMMENT_NUMBER : commentNumber + 1], forDocument: self.ref)
            
            let newCommentRef = self.fireStore.collection(IDEAS_REF).document(self.selectedIdea.documentId).collection(COMMENTS_REF).document()
            transaction.setData([
                
                COMMENT_TEXT : commentText,
                UPLOAD_DATE : FieldValue.serverTimestamp(),
                USERNAME : self.username,
                USER_ID : Auth.auth().currentUser?.uid ?? ""
                
            ], forDocument: newCommentRef)
            
            return nil
            
        } completion: { article, error in
        
            if let error = error {
                debugPrint("DEBUG: Erro Transaction \(error.localizedDescription)")
            } else {
                self.writeComment.text = ""
            }
        }
    }
    
    //MARK: - Helpers
    
    func listener() {
        
        commentsListener = fireStore.collection(IDEAS_REF).document(selectedIdea.documentId)
            .collection(COMMENTS_REF)
            .order(by: UPLOAD_DATE, descending: false)
            .addSnapshotListener({ snapshot, error in
            
            guard let snapshot = snapshot else {
                debugPrint("DEBUG: Error get comment : \(error?.localizedDescription)")
                return
            }
            
            self.comments.removeAll()
            self.comments = Comment.getComments(snapshot: snapshot)
            self.commentTableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "commentToEdit" {
            
            if let vc = segue.destination as? EditCommentController {
                
                if let data = sender as? (selectedComment : Comment, selectedPost : Idea) {
                    
                    vc.commentData = data
                    
                }
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension CommentController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell",for: indexPath) as? CommentCell {
            
            cell.configureUI(comment: comments[indexPath.row],delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK: - UITableViewDelegate

extension CommentController : UITableViewDelegate {
    
    
}

//MARK: - CommentCellDelegate

extension CommentController : CommentCellDelegate {
    
    func handleCommentOptions(comment: Comment) {
        
        let alert = UIAlertController(title: "Edit Comment", message: "", preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Delete Comment", style: .default) { action in
            //delete comment
            
            
//        self.fireStore.collection(IDEAS_REF)
//                .document(self.selectedIdea.documentId)
//                .collection(COMMENTS_REF).document(commentOptions.documentId).delete { error in
//                    if let error = error {
//                        debugPrint("DEBUG: Error while deleting comment  \(error.localizedDescription)")
//                    } else {
//                        alert.dismiss(animated: true,completion: nil)
//                    }
//                }
            
            self.fireStore.runTransaction { transaction, errorPointer in
                
                let selectedPost : DocumentSnapshot
                
                do {
                    
                    try selectedPost = transaction.getDocument(self.fireStore.collection(IDEAS_REF).document(self.selectedIdea.documentId))
                    
                } catch let error as NSError {
                    
                    
                    debugPrint("DEBUG: Idea is not found \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldComment = (selectedPost.data()?[COMMENT_NUMBER] as? Int) else { return }
                
                transaction.updateData([COMMENT_NUMBER : oldComment-1], forDocument: self.ref)
                
                let deleteCommentRef = self.fireStore.collection(IDEAS_REF).document(self.selectedIdea.documentId).collection(COMMENTS_REF).document(comment.documentId)
                transaction.deleteDocument(deleteCommentRef)
                return nil
                
            } completion: { article, error in
                
                if let error = error {
                    debugPrint("DEBUG: Error while deleting comment  \(error.localizedDescription)")
                } else {
                    alert.dismiss(animated: true,completion: nil)
                }
            }
        }
        
        let edit = UIAlertAction(title: "Edit Comment", style: .default) { action in
            //edit comment
            
            self.performSegue(withIdentifier: "commentToEdit", sender: (comment,self.selectedIdea))
            self.dismiss(animated: true,completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        alert.addAction(delete)
        alert.addAction(edit)
        alert.addAction(cancel)
        present(alert, animated: true,completion: nil)
    }
}
