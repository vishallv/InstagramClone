//
//  NotificationCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/17/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    //MARK: - Properties
    
    var delegate : NotificationCellDelegate?
    
    var notification :Notification? {
        didSet {
   
            guard let user = notification?.user else {return}
            guard let imageUrl = user.profileImageUrl else {return}
            
            profileImageView.loadImage(with: imageUrl)
            
            //configure notification labe
            configureNotificationLabel()
            
            
            //configure type of notification
            configureNotificationType()
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
            
          
            
        }
    }
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    
    let notificationLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
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
    lazy var postImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.isUserInteractionEnabled = true
        //tap gesture
        let postTapped = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTapped.numberOfTapsRequired = 1
        iv.addGestureRecognizer(postTapped)
        
        return iv
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(profileImageView)
        
        let dimension : CGFloat = 40
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = dimension/2
        
        
        
    }
    
    //MARK: - handlers
    @objc func handleFollowTapped (){
       delegate?.handleFollowTapped(for: self)
    }
    @objc func handlePostTapped () {
       delegate?.handlePostTapped(for: self)
    }
    
    //MARK: - Helper Function
    
    func configureNotificationLabel (){
        
        guard let notification = self.notification else {return}
        guard let user = notification.user else {return}
        guard let username = user.username else {return}
        
        guard let notificationDate = getNotificationTimeStamp() else {return}
//        guard let notificationMessage = notification.notificationType?.description else {return}
        let notificationMessage = notification.notificationType.description
        
        let attributedString = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        attributedString.append(NSAttributedString(string: " \(notificationMessage)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]))
        attributedString.append(NSAttributedString(string: " \(notificationDate).", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
        notificationLabel.attributedText = attributedString
        
        
    }
    
    func configureNotificationType () {
        guard let notification = self.notification else {return}
        guard let user = notification.user else {return}
        
      //  var anchor : NSLayoutXAxisAnchor!
        
        if notification.notificationType != .Follow {
            
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
        //    anchor = postImageView.leftAnchor
            
        }else {
            
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive =  true
            followButton.layer.cornerRadius = 3
       //     anchor = followButton.leftAnchor
            
            user.checkIfUserIsFollowed { (followed) in
                if followed {
                    
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                }else {
                    
                    //configure follow button
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    
                }
            }
            
        }
        
        addSubview(notificationLabel)
        notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 0)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
    func getNotificationTimeStamp() -> String?{
        
        guard let notification = self.notification else {return nil}
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second,.minute,.hour,.day,.weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        let now = Date()
        return dateFormatter.string(from: notification.creationDate, to: now)
        
        
        
    }
    
    //required INIT
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
