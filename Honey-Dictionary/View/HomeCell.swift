//
//  HomeCell.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 5.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

protocol HomeCellDelegate : class {
    func handleOptions(idea : Idea)
}

class HomeCell: UITableViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var imageLike: UIImageView!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var commentNumber: UILabel!
    @IBOutlet weak var imageOptions: UIImageView!
    
    weak var delegate : HomeCellDelegate?
    
    var selectedPost : Idea!
    
    var fireStore = Firestore.firestore()
    var likes = [Like]()
    
    //MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageViewRecog()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - Actions
    
    @objc func handleImageView() {
        
        fireStore.runTransaction { transaction, error in
            
            let selectedPost : DocumentSnapshot
            
            do {
                try selectedPost = transaction.getDocument(self.fireStore.collection(IDEAS_REF).document(self.selectedPost.documentId))
                
            } catch let error as NSError {
                
                debugPrint("DEBUG: There was error in the like \(error.localizedDescription)")
                return nil
            }
            
            guard let oldLikeNumber = (selectedPost.data()?[LIKE_NUMBER] as? Int) else { return nil }
            
            let selectedPostRef = self.fireStore.collection(IDEAS_REF).document(self.selectedPost.documentId)
            
            if self.likes.count > 0 {
                // User was like
                
                transaction.updateData([LIKE_NUMBER : oldLikeNumber-1], forDocument: selectedPostRef)
                let oldLikeRef = self.fireStore.collection(IDEAS_REF).document(self.selectedPost.documentId).collection(LIKE_REF).document(self.likes[0].documentID)
                transaction.deleteDocument(oldLikeRef)
                
            } else {
                //User was not like
                
                transaction.updateData([LIKE_NUMBER : oldLikeNumber+1], forDocument: selectedPostRef)
                let newLikeRef = self.fireStore.collection(IDEAS_REF).document(self.selectedPost.documentId).collection(LIKE_REF).document()
                transaction.setData([USER_ID : Auth.auth().currentUser?.uid ?? ""], forDocument: newLikeRef)
                
            }
            
            return nil
            
        } completion: { article, error in
            
            if let error = error {
                debugPrint("DEBUG: Error is Like \(error.localizedDescription)")
            }
        }
    }
    
    @objc func handleOptions() {
        delegate?.handleOptions(idea: selectedPost)
    }
    
    //MARK: - Helpers
    
    func fetchLike() {
        
        let isLike = fireStore.collection(IDEAS_REF).document(self.selectedPost.documentId).collection(LIKE_REF).whereField(USER_ID, isEqualTo: Auth.auth().currentUser?.uid ?? "")
        
        isLike.getDocuments { snapshot, error in
            
            self.likes = Like.getLike(snapshot: snapshot)
            
            if self.likes.count > 0 {
                
                self.imageLike.image = UIImage(named: "yildizRenkli")
                
            } else {
                
                self.imageLike.image = UIImage(named: "yildizTransparan")
                
            }
        }
    }
    
    func configureUI(idea : Idea, delegate : HomeCellDelegate?) {
        
        selectedPost = idea
        userName.text = idea.userName
        like.text = "\(idea.like ?? 0)"
        comment.text = idea.ideaText
        
        let dateFormat = DateFormatter()
        
        dateFormat.dateFormat = "dd MM YYYY, hh:mm"
        
        let date = dateFormat.string(from: idea.time)
        time.text = date
        commentNumber.text = "\(idea.comment ?? 0)"
        
        imageOptions.isHidden = true
        self.delegate = delegate
        
        if idea.userId == Auth.auth().currentUser?.uid {
            imageOptions.isHidden = false
            imageOptions.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleOptions))
            imageOptions.addGestureRecognizer(tap)
        }
        
        fetchLike()
    }
    
    func imageViewRecog() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageView))
        imageLike.addGestureRecognizer(tap)
        imageLike.isUserInteractionEnabled = true
    }

}
