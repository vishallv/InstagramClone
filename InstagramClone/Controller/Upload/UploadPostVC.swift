//
//  UploadPostVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController,UITextViewDelegate {

    
    //MARK: - Properties
    
    enum UploadAction :Int{
        
        case UploadPost
        case SaveChanges
        
        init(index : Int){
            switch index {
            case 0 : self = .UploadPost
            case 1 : self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
    var uploadAction : UploadAction!
    var selectectImage : UIImage?
    var postToEdit : Post?
    
    
    let photoImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let captionTextView : UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.init(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        return button
    }()
    
    //MARK: - INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure view componet
        configureViewComponent()
        
        //Load image
        loadImage()
        
        //text view delegate
        captionTextView.delegate = self
        
        view.backgroundColor = .white

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadAction == .SaveChanges{
            guard let post = self.postToEdit else {return}
            guard let imageUrl = post.imageUrl else {return}
            actionButton.setTitle("Save Changes", for: .normal)
            self.navigationItem.title = "Edit Post"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationController?.navigationBar.tintColor = .black
            photoImageView.loadImage(with: imageUrl)
            captionTextView.text = post.caption
        }
        else {
            actionButton.setTitle("Share", for: .normal)
            self.navigationItem.title = "Upload Post"

        }
        
            
        
      
    }
    
    func updateUserFeeds(with postID : String){
        // current user id
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        //update feed
        let values = [postID:1]
        
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerId = snapshot.key
         //   print("came in")
            USER_FEED_REF.child(followerId).updateChildValues(values)
            
        }
        //update current user feed
        
        USER_FEED_REF.child(currentUid).updateChildValues(values)
        
        
    }
    //MARK: - Handler
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleUploadAction(){
        
       buttonSelector(uploadAction: uploadAction)
        
    }
    
    func buttonSelector (uploadAction : UploadAction){
        switch uploadAction{
            
        case .UploadPost:
            handleUploadPost()
        case .SaveChanges:
            handleSavePostChanges()
    
        }
    }
    
    func handleSavePostChanges(){
        
        guard let post = self.postToEdit else {return}
        guard let postId = post.postId else {return}
        let updatedCaption = captionTextView.text
        
        uploadHashTagToServer(forPostId: postId)
        POSTS_REF.child(postId).child("caption").setValue(updatedCaption) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func handleUploadPost (){
        //parameters
        
        guard
            let caption = captionTextView.text,
            let postImage = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid  else {return}
        
        
        // Upload image data
        
        guard let uploadData = postImage.jpegData(compressionQuality: 0.5) else {return}
        
        //creation data
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //Update storoage
        
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("post_image").child(filename)
        
        Storage.storage().reference().child("post_image").child(filename).putData(uploadData, metadata: nil) { (metaData, error) in
            //handle error
            
            if let error = error{
                print("Unable to upload post:",error.localizedDescription)
                
                
            }
            //image url
            
            var URL : String?
            storageRef.downloadURL(completion: { (url, error) in
                //error
                if let error = error {
                    print("Error getting URL: ",error.localizedDescription)
                    return
                }
                
                URL = url?.absoluteString
                
                
                let values = ["caption" : caption,
                              "creationDate" : creationDate,
                              "likes" : 0,
                              "imageURL":URL,
                              "ownerUid":currentUid] as [String:Any]
                
                //POST ID
                let posID = POSTS_REF.childByAutoId()
                
                posID.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if let error = err {
                        print("Error",error.localizedDescription)
                    }
                    //Update user post structure
                    
                    
                    if  let postID = posID.key{
                        
                        USER_POSTS_REF.child(currentUid).updateChildValues([postID:1])
                        //update feed structure
                        self.updateUserFeeds(with: postID)
                        self.uploadHashTagToServer(forPostId: postID)
                        
                        //upload mention
                        if caption.contains("@"){
                            
                            self.uploadMentionNotification(forPostId: postID, withText: caption, isForComment: false)
                        }
                    }
                    
                    
                    
                    // return to homefeed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                })
                
                
            })
            
            
            
        }
        
    }
    
//    //MARK: - UitextView delagate

    func textViewDidChange(_ textView: UITextView) {
       
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor.init(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    //MARK: - Helper Function
    
    func configureViewComponent(){
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom:nil , right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    
    }
    
    func loadImage(){
        
        guard let selectedImage = self.selectectImage else {return}
        photoImageView.image = selectedImage
    }
    
    //MARK: - API call
    
    func uploadHashTagToServer (forPostId postId : String){
        
        guard let caption = captionTextView.text else {return}
        
        let words : [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words{
            
            if word.hasPrefix("#")
            {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashTagValue = [postId:1]
                
                HASH_TAG_POST.child(word.lowercased()).updateChildValues(hashTagValue)
                
            }
        }
    }
    
    



}
