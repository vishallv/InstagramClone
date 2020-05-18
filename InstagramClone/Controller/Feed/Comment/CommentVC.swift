//
//  CommentVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/15/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"
class CommentVC : UICollectionViewController,UICollectionViewDelegateFlowLayout {
 
    //MARK: - Propoerties
    
    var comments = [Comment]()
    var post : Post?
    
    lazy var containerView : CommentInputAccessoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
      
        let containerView = CommentInputAccessoryView(frame: frame)
        
//        containerView.addSubview(postButton)
//        postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
//        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
//        containerView.addSubview(commentTextField)
//        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
     
        
//        let seperatorView = UIView()
//        seperatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
//
//        containerView.addSubview(seperatorView)
//        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        containerView.backgroundColor = .white
        containerView.delegate = self
        return containerView
    }()
    
//    let commentTextField : UITextField = {
//        let tf = UITextField()
//        tf.placeholder = "Enter Comment"
//        tf.font = UIFont.systemFont(ofSize: 14)
//        return tf
//    }()
//    
//    let postButton : UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Post", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        button.addTarget(self, action: #selector(hanleUploadComment), for: .touchUpInside)
//        return button
//    }()
    //MARK: - init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure collection view
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        //set Navigation bar title
        navigationItem.title = "Comment"
        
        //register cell at comment cell
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //fetch comments
        fetchComment()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    //MARK: UIcollection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.row]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimateSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40+8+8, estimateSize.height)
        return CGSize(width: view.frame.width, height: height)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        
        cell.comment = self.comments[indexPath.row]
        handleHashTagTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        
        return cell
        
    }
    
    //MARK: - Handlers

    
    func handleHashTagTapped (forCell cell : CommentCell){
        cell.commentLabel.handleHashtagTap { (hashTag) in
            let hashTagController = HashTagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashTagController.hashTag = hashTag
            self.navigationController?.pushViewController(hashTagController, animated: true)
        }
    }
    
    func handleMentionTapped(forCell cell : CommentCell){
        cell.commentLabel.handleMentionTap { (username) in
           
            self.getMentionedUser(withUsername: username)
        }
        
    }
    
    //MARK: - Helper function
    
    
    func fetchComment (){
        
        guard let post = self.post else {return}
        guard let postId = post.postId else {return}
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String,AnyObject> else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            
            Database.fetchUser(with: uid, completion: { (user) in
                let comment = Comment(user : user,dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            })
            
           
        }
        
    }
    
    
    
    func uploadCommentNotificationToServer (){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let post = self.post else {return}
        guard let postId = post.postId else {return}
        guard let uid = post.user.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //NOTIFICATION VALUE
        let values = ["checked": 0,
                      "creationDate":creationDate,
                      "uid":currentUid,
                      "type": COMMENT_INT_VALUE,
                      "postId":postId] as [String:Any]
        
        //upload comment notification to server
        
        if uid != currentUid{
            
            NOTIFICATION_REF.child(uid).childByAutoId().updateChildValues(values)
        }
        
        
    }
    
}

extension CommentVC : CommentInputAccessoryViewDelegate{
    func didSubmit(forComment comment: String) {
    
        guard let post = self.post else {return}
        guard let postId = post.postId else {return}
//        guard let commentText = commentTextField.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let creationDate = (NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment,
                      "creationDate":creationDate,
                      "uid":uid] as [String:Any]
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            self.uploadCommentNotificationToServer()
            if comment.contains("@"){
                self.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: true)
            }
          
            self.containerView.clearCommentTextView()
        }
        
        
    }
    
    
}
