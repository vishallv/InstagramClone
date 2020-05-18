//
//  FollowVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/7/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"
class FollowLikeVC : UITableViewController , FollowCellDelegate{

    
    //MARK: - Properties
    
    var followCurrentKey : String?
    var likeCurrentKey : String?
    
    
    //create a enum
    enum ViewingMode : Int {
        case Following
        case Followers
        case Likes
        
        init(index : Int){
            switch index {
            case 0 : self = .Following
            case 1 : self = .Followers
            case 2 : self = .Likes
            default : self = .Following
            }
        }
    }
    
    
    //     var viewFollowers = false
    //     var viewFollowing = false
    var postId : String?
    var viewingMode : ViewingMode!
    var uid : String?
    var users = [User]()
    
    
    //MARK: - INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        
            // configure nav title bar
            configureNavTitiel()
        
            //fetch users
            fetchUsers()
        
        //        if viewFollowers{
        //       navigationItem.title  = "Followers"
        //        }
        //        if viewFollowing{
        //
        //            navigationItem.title  = "Following"
        //        }
        
        tableView.separatorColor = .clear
        
        
        
        
    }
    //MARK: - handle follow cell delegate
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        
        guard let user = cell.user else {return}
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
        else{
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
            
        }
    }
    
    //MARK: - Table view functions
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3{
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        
        cell.user = self.users[indexPath.row]
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        let profileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - configure nav bar
    func configureNavTitiel (){
        
        guard let viewingMode = self.viewingMode else {return }

        switch viewingMode {
        case  .Followers : navigationItem.title = "Follwers"
        case .Following : navigationItem.title = "Follwing"
        case .Likes :    navigationItem.title = "Likes"
        }
    }
    
    //MARK: - API
    
    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else {return nil}
        switch viewingMode {
        case .Followers: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
        }
        
    }
    
    func fetchUser (with uid : String){
        
        Database.fetchUser(with: uid, completion: { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        })
    }
    
    func fetchUsers(){
        
        
        guard let viewingMode = self.viewingMode else {return }

        guard let ref = getDatabaseReference() else {return}
        
        //        if viewFollowers{
        //            //Fetch followers
        //
        //            ref = USER_FOLLOWER_REF
        //        }
        //        else{
        //            // fetch following
        //            ref = USER_FOLLOWING_REF
        //        }
        switch viewingMode{
            
        case .Followers , .Following :
            guard let uid = self.uid else {return}
            
            if followCurrentKey == nil{
                
                
                ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                    
                    allObjects.forEach({ (snapshot) in
                        let followUid = snapshot.key
                        
                        self.fetchUser(with: followUid)
                    })
                    self.followCurrentKey = first.key
                    
                }
            }
            else {
                ref.child(uid).queryOrderedByKey().queryEnding(atValue: self.followCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                    
                    allObjects.forEach({ (snapshot) in
                        let followUid = snapshot.key
                        
                        if followUid != self.followCurrentKey{
                        self.fetchUser(with: followUid)
                        }
                    })
                    self.followCurrentKey = first.key
                    
                }
                
                
            }
            
            
//            ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
//
//                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
//
//                allObjects.forEach({ (snapshot) in
//                    let uid = snapshot.key
//                    self.fetchUser(with: uid)
//
//                })
//
//            }
            
        case .Likes :
            
            
            guard let postId = self.postId else {return}
            
            if likeCurrentKey == nil {
                
                ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        
                        self.fetchUser(with: likeUid)
                    })
                    self.likeCurrentKey = first.key
                    
                }
            }
            else {
                ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        
                        if likeUid != self.likeCurrentKey{
                            self.fetchUser(with: likeUid)
                        }
                    })
                    self.likeCurrentKey = first.key
                    
                }
                
                
            }
            
//            ref.child(postId).observe(.childAdded) { (snapshot) in
//               let uid = snapshot.key
//                self.fetchUser(with: uid)
//
//            }
            
        }
        
        
        
    }
    
}
