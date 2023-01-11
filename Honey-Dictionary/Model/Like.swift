//
//  Like.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 10.01.2023.
//

import Foundation
import Firebase


class Like {
    
    private(set) var userID : String
    private(set) var documentID : String
    
    init(userID: String, documentID: String) {
        self.userID = userID
        self.documentID = documentID
    }
    
    class func getLike(snapshot : QuerySnapshot?) -> [Like] {
        
        var likes = [Like]()
        
        guard let snap = snapshot else { return likes }
        
        for record in snap.documents {
            
            let data = record.data()
            let userId = data[USER_ID] as? String ?? ""
            let documentId = record.documentID
            
            let newLike = Like(userID: userId, documentID: documentId)
            likes.append(newLike)
        }
        return likes
    }
}
