//
//  Comment.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/16/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    var user: User?
    var commentText : String!
    var creationDate : Date!
    var uid :String!
    
    init (user :User, dictionary : Dictionary<String,AnyObject>){
        
        self.user = user
        if let uid = dictionary["uid"] as? String {
           self.uid = uid
        }
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            //  print(creationDate)
            
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
    }
}
