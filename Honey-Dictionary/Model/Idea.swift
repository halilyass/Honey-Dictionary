//
//  Idea.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 5.01.2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class Idea {
    
    private(set) var userName : String!
    private(set) var time : Date!
    private(set) var ideaText : String!
    private(set) var comment : Int!
    private(set) var like : Int!
    private(set) var documentId : String!
    private(set) var userId : String!
    
    init(userName: String, time: Date, ideaText: String, comment: Int, like: Int, documentId: String,userId : String) {
        self.userName = userName
        self.time = time
        self.ideaText = ideaText
        self.comment = comment
        self.like = like
        self.documentId = documentId
        self.userId = userId
    }
    
    class func getIdeas(snapshot : QuerySnapshot?, dailyPost : Bool = false) -> [Idea] {
        
        var ideas = [Idea]()
        
        guard let snap = snapshot else { return ideas}
        
        for document in snap.documents {
            
            let data = document.data()
            
            let username = data[USER_NAME] as? String ?? "Misafir"
            
            let timeStamp = data[UPLOAD_DATE] as? Timestamp ?? Timestamp()
            let date = timeStamp.dateValue()
            
            if dailyPost == true && Calendar.current.isDateInToday(date) == false {
                continue
            }
            
            let ideaText = data[IDEAS_TEXT] as? String ?? ""
            let comment = data[COMMENT_NUMBER] as? Int ?? 0
            let like = data[LIKE_NUMBER] as? Int ?? 0
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newIdea = Idea(userName: username, time: date, ideaText: ideaText, comment: comment, like: like, documentId: documentId,userId: userId)
            ideas.append(newIdea)
        }
        
        return ideas
        
    }
    
}
