//
//  File.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 9.01.2023.
//

import Foundation
import Firebase

class Comment {
    private(set) var username : String!
    private(set) var date : Date!
    private(set) var commentText : String!
    private(set) var documentId : String!
    private(set) var userId : String!
    
    init(username: String, date: Date, commentText: String,documentId: String, userId: String) {
        self.username = username
        self.date = date
        self.commentText = commentText
        self.documentId = documentId
        self.userId = userId
    }
    
    class func getComments(snapshot : QuerySnapshot?) -> [Comment] {
        
        var comments = [Comment]()
        
        guard let snap = snapshot else { return comments}
        
        for record in snap.documents {
            
            let data = record.data()
            
            let username = data[USER_NAME] as? String ?? "Misafir"
            let timeStamp = data[UPLOAD_DATE] as? Timestamp ?? Timestamp()
            let date = timeStamp.dateValue()
            
            let comment = data[COMMENT_TEXT] as? String ?? "Comment is not found"
            let documentId = record.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newComment = Comment(username: username, date: date, commentText: comment,documentId: documentId,userId: userId)
            
            comments.append(newComment)
            
        }
        
        return comments
        
    }
}
