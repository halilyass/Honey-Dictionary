//
//  CommentCell.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 9.01.2023.
//

import UIKit
import FirebaseAuth

protocol CommentCellDelegate : class {
    func handleCommentOptions(comment : Comment)
}

class CommentCell: UITableViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var imageOptions: UIImageView!
    
    weak var delegate : CommentCellDelegate?
    
    var selectedPost : Comment!
    
    //MARK: - Lifecyle

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: - Actions
    
    @objc func handleCommentOptions() {
        delegate?.handleCommentOptions(comment: selectedPost)
    }
    
    //MARK: - Helpers
    
    func configureUI(comment : Comment,delegate : CommentCellDelegate?) {
        
        userName.text = comment.username
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd MM YYYY, hh:mm"
        let addCommentDate = dateFormat.string(from: comment.date)
        date.text = addCommentDate

        commentText.text = comment.commentText
        
        selectedPost = comment
        self.delegate = delegate
        imageOptions.isHidden = true
        
        if comment.userId == Auth.auth().currentUser?.uid {
            
            imageOptions.isHidden = false
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCommentOptions))
            imageOptions.isUserInteractionEnabled = true
            imageOptions.addGestureRecognizer(tap)
        }
    }
}
