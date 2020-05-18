//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/5/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    //MARK: - properties
    
    var user : User? {
        didSet{
            
            guard let profileImageUrl = user?.profileImageUrl else {return}
            guard let username = user?.username else {return}
            guard let fullname = user?.name else {return}
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname
        }
    }
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        
        let dimension : CGFloat = 48
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
         profileImageView.layer.cornerRadius = dimension/2
     //   profileImageView.clipsToBounds = true
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "Full name"
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
    
}
