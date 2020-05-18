//
//  User.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/4/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import Firebase

class User {
    // Atributes
    
    var username : String!
    var name : String!
    var profileImageUrl : String!
    var uid : String!
    var isFollowed = false
    
    init (uid:String , dictionary : Dictionary <String , AnyObject>){
        
        self.uid = uid
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        if let name = dictionary["fullname"] as? String {
            self.name = name
        }
        if let profileImageUrl = dictionary["profileImageURl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: - get uid like this to work with update
        guard let uid = uid else { return }
        
        // set is followed is true
        self.isFollowed = true
    
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        //upload follow notification to server
        uploadFollowNotificationToServer()
        
        //add follwed post to current user feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            
            let postID = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postID:1])
        }
        
        
   
    }
    
    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: - get uid like this to work with update
        guard let uid = uid else { return }
        
        // set is followed to false
        self.isFollowed = false
   
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        //remove feed of unfollwed user
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postID = snapshot.key
            
            USER_FEED_REF.child(currentUid).child(postID).removeValue()
        }
        
        
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> ()){
         guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(self.uid){
                self.isFollowed = true
               completion(true)
            }
            else{
                self.isFollowed = false
                 completion(false)
            }
        }
        
    }
    
    func uploadFollowNotificationToServer (){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        guard  let uid = self.uid else {return}
        
        //NOTIFICATION VALUE
        let values = ["checked": 0,
                      "creationDate":creationDate,
                      "uid":currentUid,
                      "type": FOLLOW_INT_VALUE] as [String:Any]
        
        NOTIFICATION_REF.child(uid).childByAutoId().updateChildValues(values)
    }
   
    
}
