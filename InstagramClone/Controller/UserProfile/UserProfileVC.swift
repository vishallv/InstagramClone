//
//  UserProfileVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"
private let userPostCellIdentifier = "UserPostCell"

class UserProfileVC: UICollectionViewController,UICollectionViewDelegateFlowLayout,UserProfileHeaderDelegate {
  
    
  

    //MARK: - Properties
    
//    var currentUser : User?
//    var userToLoadFromSeachVC  :User?
    var user : User?
    var posts = [Post]()
    var currentKey : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: userPostCellIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
       
        //confifure refresh control
        
        configureRefreshControl()
        
        // background color
        self.collectionView.backgroundColor = .white
        //fetch user data
        if self.user == nil{
        fetchCurrentUserData()
        }
        fetchPost()
        
    
        
        
    }
    //Collectionviewflow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)/3
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 9{
            
            if indexPath.item == posts.count - 1{
                fetchPost()
            }
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        
            header.delagate = self
        
//                if let user = self.currentUser{
//                    header.user = user
//                }
//                else if let userToLoadFromSeachVC = self.userToLoadFromSeachVC{
//                    header.user = userToLoadFromSeachVC
//                    navigationItem.title = userToLoadFromSeachVC.username
//                }
        header.user = self.user
        navigationItem.title = user?.username
        
    
        return header
    }
   
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userPostCellIdentifier, for: indexPath) as! UserPostCell
        
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.userProfileController = self
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
        
    }
    // MARK: - USer Profile header Protocol
    func handleEditFollowTapped(for header: UserProfileHeader) {
       
        guard let user = header.user else {return}
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            
            let editProfileVC = EditProfileController()
            editProfileVC.user = user
            editProfileVC.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileVC)
            
            
            present(navigationController,animated: true,completion: nil)
            
        }
        else {
            if header.editProfileFollowButton.titleLabel?.text == "Follow"{
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            }
            else{
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else {return}
        var numberOfFollower : Int!
        var numberOfFollowing : Int!
        
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String,AnyObject> {
                numberOfFollower = snapshot.count
            }else
            {
                numberOfFollower = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollower!)\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "Follower", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
            header.followLabel.attributedText = attributedString
            
            
        }
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String,AnyObject> {
                numberOfFollowing = snapshot.count
            }else
            {
                numberOfFollowing = 0
            }
            let attributedString = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
            header.followingLabel.attributedText = attributedString
            
        }
    }
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        
      //  print("Handle Follower tapped")
        
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
      //  followVC.viewFollowers = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
       // print("handle following tapped")
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
       // followVC.viewFollowing = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    //MARK: - Refresh
    
    func configureRefreshControl (){
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }

    @objc func handleRefresh (){
        
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPost()
        collectionView.reloadData()
    }
    
    //MARK: - API
    
    func fetchPost(){
        
        var uid : String!
        if let user = self.user {
            uid = user.uid
        }else {
            uid = Auth.auth().currentUser?.uid
        }
        
        if currentKey == nil{
            //initaial data pull
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                  self.fetchPaginatingPost(withPostId: postId)
                    
                })
                
                self.currentKey = first.key
            }
            
        }else {
            
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (snapshot) in
                
             
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey{
                        self.fetchPaginatingPost(withPostId: postId)
                    }
                })
                
                self.currentKey = first.key
            }
            
        }
        
        
//        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
//
//            let postID = snapshot.key
//
//            Database.fetchPost(postId: postID, completion: { (post) in
//                self.posts.append(post)
//
//                self.posts.sort(by: { (post1, post2) -> Bool in
//                    return post1.creationDate > post2.creationDate
//                })
//                self.collectionView.reloadData()
//            })
//
//        }
        
    }
    func fetchPaginatingPost(withPostId postId : String){
        Database.fetchPost(postId: postId) { (post) in
            self.posts.append(post)
            
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView.reloadData()
        }
        
    }
    

    
    
    
    func fetchCurrentUserData(){
        
                guard let currentUID = Auth.auth().currentUser?.uid else{return}
        
                Database.database().reference().child("User").child(currentUID).observeSingleEvent(of: .value) { (snapshot) in

                    guard let dictionary = snapshot.value as? Dictionary<String,AnyObject> else {return}
        
                    let uid = snapshot.key
                    let user = User(uid: uid, dictionary: dictionary)
                    self.user = user
                    self.navigationItem.title = user.username
                    self.collectionView.reloadData()
                    
                }
    }
    
    
}
