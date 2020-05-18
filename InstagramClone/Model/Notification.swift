//
//  Notification.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/18/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import Foundation
import Firebase


class Notification {
    
    enum NotificationType : Int,Printable {
 
        case Like
        case Comment
        case Follow
        case CommentMention
        case PostMention
        
        var description: String {
            
            switch self {
            case .Like : return " Liked yor post"
            
            case .Comment : return " commentend on your post"
            
            case .Follow : return " started followed you"
            case .CommentMention: return " mentioned you in a comment"
            case .PostMention: return " mentioned you in a post"
            }}
            
            init(index : Int){
                switch index {
                case 0 : self = .Like
                case 1 : self = .Comment
                case 2 : self = .Follow
                case 3 : self = .CommentMention
                case 4 : self = .PostMention
                default : self = .Like
                }
        }
      
    }
    
    var creationDate : Date!
    var uid : String!
    var postId : String?
    var post : Post?
    var user : User!
    var notificationType : NotificationType!
    var didCheck  = false
    var type : Int?
    
    init (user : User, post : Post? = nil , dictionary : Dictionary<String,AnyObject>){
        
        self.user = user
        if let post = post {
            self.post = post
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let type = dictionary["type"] as? Int {
           // self.type = type
            self.notificationType = NotificationType(index: type)
        }
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary["postId"] as? String{
            self.postId = postId
        }
        
        if let checked = dictionary["checked"] as? Int {
            
            if checked == 0 {
                self.didCheck = false
            }else {
                self.didCheck = true
            }
        }
        
    }
    
    
    
}
