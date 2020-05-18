//
//  Post.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/11/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//
import Foundation
import Firebase


class Post {
    
    var caption : String!
    var likes : Int!
    var imageUrl : String!
    var ownerUid : String!
    var creationDate : Date!
    var postId : String!
    var user : User!
    var didLike = false
    
    init (postId : String!,user : User, dictionary : Dictionary<String,AnyObject>)
    {
        
        self.postId = postId
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            //  print(caption)
            self.caption = caption
        }
        if let likes = dictionary["likes"] as? Int {
            //   print(likes)
            self.likes  = likes
        }
        if let imageUrl = dictionary["imageURL"] as? String {
            //   print(imageUrl)
            self.imageUrl = imageUrl
        }
        
        if let ownerId = dictionary["ownerUid"] as? String {
            //   print(ownerId)
            self.ownerUid = ownerId
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            //  print(creationDate)
            
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
    }
    
    func adjustLikes(addLike : Bool , completion : @escaping(Int) -> ()){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        guard let ownerUid = self.ownerUid else{return}
        
        guard let postId = self.postId else{return}
        if addLike {
            
            
           
            //Update user like structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId:1]) { (error, ref) in
                
                //send notification to server
                
                self.sendLikeNotificationToServer()
                
                //update post like strusture
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid:1], withCompletionBlock: { (error, ref) in
                    
                    self.likes  = self.likes + 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                    
                })
            }
            
            
            
        }
        else {
            
            
            
            //remove notification from server
            
            //pbserve one server
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                
                //notification id from server
                
                guard let notificationId = snapshot.value  as? String else {return}
                
                //remove notification from server
                
                NOTIFICATION_REF.child(ownerUid).child(notificationId).removeValue(completionBlock: { (error, ref) in
                    
                    //remove user like structure
                    USER_LIKES_REF.child(currentUid).child(postId).removeValue { (error, ref) in
                        
                        //remove post like strusture
                        POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock: { (error, ref) in
                            
                            guard self.likes > 0 else{return}
                            self.likes = self.likes - 1
                            self.didLike = false
                            completion(self.likes)
                            POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                            
                        })
                    }
                })
            }
            
            
            
            
            
        }
        
        
    }
    
    func deletePost(){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snaphot) in
            let followerUid = snaphot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        USER_FEED_REF.child(currentUid).child(self.postId).removeValue()
        
        USER_POSTS_REF.child(currentUid).child(self.postId).removeValue()
        
        POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
            let uid  = snapshot.key
            
            
            USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let notificationId = snapshot.value as? String else {return}
                
                NOTIFICATION_REF.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    
                    POST_LIKES_REF.child(self.postId).removeValue()
                    
                    USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                    
                })
            })
        }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                HASH_TAG_POST.child(word).child(postId).removeValue()
            }
        }
        
        COMMENT_REF.child(postId).removeValue()
        
        POSTS_REF.child(postId).removeValue()
    }
    
    func sendLikeNotificationToServer (){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        guard let ownerUid = self.ownerUid else{return}
        guard let postId = self.postId else{return}
        //only likes from different users
        if currentUid != ownerUid{
            
            //NOTIFICATION VALUE
            let values = ["checked": 0,
                          "creationDate":creationDate,
                          "uid":currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId":postId] as [String:Any]
            
            //upload notification database ref
            let notificationREF = NOTIFICATION_REF.child(ownerUid).childByAutoId()
            
            //opplaod vlaues to database
            notificationREF.updateChildValues(values) { (error, ref) in
                USER_LIKES_REF.child(currentUid).child(postId).setValue(notificationREF.key)
            }
            
        }
    }
    
}
