//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    //MARK: - Properties
    
    var delagate : UserProfileHeaderDelegate?
    var user : User? {
        didSet{
            
            configureEditProfileFollowButton()
            setUserStas(for: user)
            let fullname = user?.name
            nameLabel.text = fullname
            
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(with: profileImageUrl)
            
        }
    }
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        //        label.text = "Batman lakshmi"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let postLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        let attributedString = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
        attributedString.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
        label.attributedText = attributedString
        return label
    }()
    
    lazy var followLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
                let attributedString = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
                attributedString.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
                label.attributedText = attributedString
        
        // add tap gesture
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowerTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    lazy var followingLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
                let attributedString = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
                attributedString.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
                label.attributedText = attributedString
        
        // add tap gesture
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        //        let attributedString = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
        //        attributedString.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
        //        label.attributedText = attributedString
        return label
    }()
    
    lazy var editProfileFollowButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        button.backgroundColor = .white
        
        
        return button
    }()
    
    let gridButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    let listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        let dimension : CGFloat = 80
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.layer.cornerRadius = dimension/2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height:  0)
        configureUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        configureBottomToolBar()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Function
    func configureBottomToolBar(){
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton,listButton,bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    func configureUserStats (){
        
        let stackView = UIStackView(arrangedSubviews: [postLabel,followLabel,followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    func setUserStas(for user : User?){
        delagate?.setUserStats(for: self)
        
        
    }
    
    func configureEditProfileFollowButton(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let user = self.user else {return}
        
        if currentUid == user.uid{
            //Configure Edit Button
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
        }
        else {
            
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            user.checkIfUserIsFollowed { (followed) in
                
                
                if followed{
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                }
                else{
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                    
                }
            }
            
        }
        
    }
    
    //MARK: - Selector
    @objc func handleEditProfileFollow(){
        
        delagate?.handleEditFollowTapped(for: self)
        
    }
    
    @objc func handleFollowerTapped(){
        delagate?.handleFollowersTapped(for: self)
    }
    
    @objc func handleFollowingTapped(){
        delagate?.handleFollowingTapped(for: self)
    }
    
}
