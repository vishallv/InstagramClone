//
//  FeedCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/12/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var delegate : FeedCellDelegate?
    
    var post : Post?  {
    didSet {
        
        guard let ownerUid = post?.ownerUid else {return}
        
        Database.fetchUser(with: ownerUid) { (user) in
            
            let user = user
            self.profileImageView.loadImage(with: user.profileImageUrl)
            self.usernameButton.setTitle(user.username, for: .normal)
              //captionLabel.text = caption
            self.configureCaption(user: user)
        }
        
        guard let imageURl = post?.imageUrl , let likes = post?.likes else {return}
        postImageView.loadImage(with: imageURl)
        likesLabel.text = "\(String(likes)) likes"
        configureLikeButton()
    
    }
    }
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var usernameButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var optionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleOptionTapped), for: .touchUpInside)
        return button
        
    }()
    lazy var postImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        //add gesture recognizer
        
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(likeTap)
        return iv
    }()
    lazy var likeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
       button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
        
    }()
    lazy var commentButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
        
    }()
    let messageButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        return button
        
    }()
    let savePostButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = .black
        return button
        
    }()
    
    lazy var likesLabel : UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "3 likes"
        
        // add gesture recognizer
        
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(hadleShowLikes))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        return label
    }()
    
    let captionLabel  : ActiveLabel = {
        
        let label = ActiveLabel()
        label.numberOfLines = 0
        return label
    }()
    
    let postTimeLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    
    //MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dimension: CGFloat = 40
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.layer.cornerRadius = dimension/2
        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    //MARK: - Handler
    
    @objc func handleUsernameTapped(){
        delegate?.handleUsernameTapped(for: self)
        
    }
    @objc func handleOptionTapped(){
        delegate?.handleOptionTapped(for: self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
        
    }
    @objc func handleCommentTapped(){
        delegate?.handleCommentTapped(for: self)
    }
    @objc func hadleShowLikes(){
        delegate?.handleShowLikes(for: self)
    }
    
    @objc func handleDoubleTapToLike(){
      delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    
    func configureLikeButton (){
        delegate?.handleConfigureLikeButton(for: self)
    }
    //MARK: - HelperFunction
    
    func configureCaption (user: User){
        
        guard let post = self.post else {return}
        guard let caption = post.caption else {return}
        guard let username = post.user.username else {return}
        
        //look for username as pattern
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        //enable user for custom type
        
        captionLabel.enabledTypes = [.mention,.hashtag,.url,customType]
        
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            
            var atts = attributes
            
            switch type{
            case .custom :
                atts[NSAttributedString.Key.font ] = UIFont.boldSystemFont(ofSize: 12)
            default : ()
            }
            
            return atts
        }
        
        captionLabel.customize { (label) in
            label.text = "\(username)  \(caption)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            captionLabel.numberOfLines = 2
            
        }
        
        postTimeLabel.text = post.creationDate.timeAgoToDisplay()
        
//        let attrtributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
//        attrtributedText.append(NSAttributedString(string: "  \(caption)" , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
//        captionLabel.attributedText = attrtributedText
        
    }
    
    func configureActionButtons (){
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,messageButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
