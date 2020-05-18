//
//  FollowCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/7/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class FollowLikeCell: UITableViewCell {

    //MARK: - Properties
    
    var delegate : FollowCellDelegate?
    
    var user : User? {
        didSet{
            
            guard let profileImageUrl = user?.profileImageUrl else {return}
            guard let username = user?.username else {return}
            guard let fullname = user?.name else {return}
            
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname
            
            if user?.uid == Auth.auth().currentUser?.uid{
                followButton.isHidden = true
            }
            
            user?.checkIfUserIsFollowed(completion: { (followed) in
                if followed{
                    // configure following button
                    
                    self.followButton.configure(didFollow: true)
                }
                else {
                    
                    //configure follow button
                    self.followButton.configure(didFollow: false)
                    
                }
            })
        }
    }
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var followButton : UIButton = {
        
        let button = UIButton(type: .system)
        
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        
        let dimension : CGFloat = 48
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = dimension/2
        textLabel?.text = "USername"
        detailTextLabel?.text = "Full name"
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive =  true
        
        self.selectionStyle = .none
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: (detailTextLabel?.frame.origin.y)! , width: self.frame.width - 108, height: (detailTextLabel?.frame.height)!)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Handlers
    @objc func handleFollowTapped(){
        delegate?.handleFollowTapped(for: self)
       // print("Handle follow tapped")
    }
}
