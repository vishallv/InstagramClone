//
//  FeedVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController,UICollectionViewDelegateFlowLayout,FeedCellDelegate {

    
    //MARK: - Properties
    var viewSinglePost = false
    var posts = [Post]()
    var post : Post?
    var currentKey : String?
    var userProfileController : UserProfileVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //add refresh controller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefeshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        configureNavBar()
        //fetch post
        
        if !viewSinglePost{
            fetchPost()
        }
        updateUserFeed()
        
    }
    
    //UicollectionviewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 56 + 50 + 60
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
            if posts.count > 4{
                if indexPath.item == posts.count - 1{
                    fetchPost()
                    
                }
            }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if viewSinglePost{
            return 1
        }else {
            return posts.count
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if viewSinglePost{
            
            if  let post = self.post {
                cell.post = post
                
            }
        }
        else {
            cell.post = posts[indexPath.row]
        }
        
        handleHashTagTapped(forCell: cell)
        handleLabelUsernameTapped(withCell: cell)
        handleMentionTapped(forCell: cell)
        return cell
    }
    //FeedCell Delegate
    
    
    //MARK: - Handlers
    
    func handleLabelUsernameTapped (withCell cell :FeedCell){
        
        guard let user = cell.post?.user else {return}
        guard let username = cell.post?.user.username else {return}
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.captionLabel.handleCustomTap(for: customType) { (_) in
           
            let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.user = user
            self.navigationController?.pushViewController(userProfileVC, animated: true)
            
        }
    }
    
    func handleMentionTapped(forCell cell : FeedCell){
        cell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
    }
    
    func handleHashTagTapped(forCell cell : FeedCell){
        cell.captionLabel.handleHashtagTap { (hashtag) in
            
            let hashTagVC = HashTagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashTagVC.hashTag = hashtag
            
            self.navigationController?.pushViewController(hashTagVC, animated: true)
        }
        
    }
    
    func handleUsernameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else{return}
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else {return}
        guard let postId = post.postId  else {return}
        
        guard let currenUid = Auth.auth().currentUser?.uid else {return}
        
        USER_LIKES_REF.child(currenUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(postId){
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
            
        }
        
    }
    
    func handleOptionTapped(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        if post.ownerUid == currentUid{
        let alertController = UIAlertController(title: "Option", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
            //delete post
            
            post.deletePost()
            
            if !self.viewSinglePost{
                self.handleRefeshControl()
            }else {
                
                if let userProfileVC = self.userProfileController{
                     _ = self.navigationController?.popViewController(animated: true)
                    userProfileVC.handleRefresh()
                }
               
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
           
            let uploadPostController = UploadPostVC()
            let navigationController = UINavigationController(rootViewController: uploadPostController)
            uploadPostController.postToEdit = post
            uploadPostController.uploadAction = UploadPostVC.UploadAction(index: 1)
            self.present(navigationController ,animated: true , completion: nil)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController,animated: true,completion: nil)
        }
        
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap:Bool) {
        guard let post = cell.post else {return}
        
        if post.didLike {
            
            if !isDoubleTap{
                //to unlike a post
                post.adjustLikes(addLike: false) { (likes) in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                   // self.sendLikeNotificationToServer(post: post, didLike: false)
                }}
            
            
            
        }
        else {
            
            //like a post
            post.adjustLikes(addLike: true) { (likes) in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
               // self.sendLikeNotificationToServer(post: post, didLike: true)
                
            }
            
        }
        
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
     //   guard let postId = post.postId else {return}
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    func handleShowLikes(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
        guard let postId = post.postId else {return}
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    
    @objc func handleRefeshControl(){
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPost()
        collectionView.reloadData()
    }
    
    
    
    func configureNavBar (){
        if !viewSinglePost{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogOut))
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }
    
    @objc func handleLogOut(){
        
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add alert action
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController,animated:  true,completion: nil)
                print("Logged out User")
            }
            catch{
                // error
                print("Failed to sign out")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true,completion: nil)
    }
    
    @objc func handleShowMessages(){
        let messagesController = MessagesCOntroller()
        
        navigationController?.pushViewController(messagesController, animated: true)
    }
    //MARK: - API
    
    func updateUserFeed (){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followingUserId = snapshot.key
            USER_POSTS_REF.child(followingUserId).observe(.childAdded, with: { (snapshot) in
                
                let postId = snapshot.key
                USER_FEED_REF.child(currentUid).updateChildValues([postId:1])
                
            })
            
        }
        USER_POSTS_REF.child(currentUid).observe(.childAdded, with: { (snapshot) in
            
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId:1])
            
        })
        
        
    }
    
    func fetchPost(){
        
     
        
        guard let currentuid = Auth.auth().currentUser?.uid else {return}
        
        
        
        if currentKey == nil{
            USER_FEED_REF.child(currentuid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
                guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObject.forEach({ (snapshot) in
                    let postId = snapshot.key
                    self.fetchPaginatingPost(withPostId: postId)
                })
                self.currentKey = first.key
            }
            
        }
        else {
            USER_FEED_REF.child(currentuid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
                guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObject.forEach({ (snapshot) in
                    let postId = snapshot.key
                    if postId != self.currentKey{
                         self.fetchPaginatingPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
               
            }
        }
        
        //        POSTS_REF.observe(.childAdded) { (snapshot) in
        
//        USER_FEED_REF.child(currentuid).observe(.childAdded) { (snapshot) in
//            let postID = snapshot.key
//
//            Database.fetchPost(postId: postID, completion: { (post) in
//                self.posts.append(post)
//
//                self.posts.sort(by: { (post1, post2) -> Bool in
//                    return post1.creationDate > post2.creationDate
//                })
//
//
//                //stop refreshing
//                self.collectionView.refreshControl?.endRefreshing()
//
//                self.collectionView.reloadData()
//            })
//
//
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
    
}
