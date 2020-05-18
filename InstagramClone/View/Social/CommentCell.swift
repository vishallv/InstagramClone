//
//  CommentCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/15/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var comment : Comment? {
        didSet {
            guard let imageUrl = comment?.user?.profileImageUrl else {return}
//            guard let username = comment?.user?.username else {return}
//            guard let commentText = comment?.commentText else {return}
//            guard let commentDate = getCommentTimeStamp() else {return}
            
            configureCommentLabel()
            
//            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
//            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]))
//            attributedText.append(NSAttributedString(string: " \(commentDate).", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
//            commentLabel.attributedText = attributedText
            
            profileImageView.loadImage(with: imageUrl)
            
            
            
        }
    }
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let commentLabel  : ActiveLabel = {
        
        let label =  ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0 
        return label
    }()
//    let seperatorView : UIView = {
//        let view = UIView()
//
//        view.backgroundColor = UIColor.lightGray
//        return view
//
//
//    }()
    
    //MARK: - INit
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        
        let dimension : CGFloat = 40
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = dimension/2
        
        addSubview(commentLabel)
        commentLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
       
      
    }
    
    //MARK: - Helper Function
    
    func getCommentTimeStamp() -> String?{
        
        guard let comment = self.comment else {return nil}
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second,.minute,.hour,.day,.weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        let now = Date()
        return dateFormatter.string(from: comment.creationDate, to: now)
        
        
        
    }
    
    func configureCommentLabel () {
        
        guard let comment = self.comment else {return}
        guard let user = comment.user else {return}
        guard let username = user.username else{return}
        guard let commentText = comment.commentText else {return}
        
        
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        commentLabel.enabledTypes = [.mention,.hashtag,customType,.url]

        
        commentLabel.configureLinkAttribute = { (type , attributes , isSelected) in
            
            var atts = attributes
            
            switch type{
            case .custom :
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default : ()
            }
            return atts
            
        }
        
        commentLabel.customize { (label) in
            label.text = "\(username)  \(commentText)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 0
            
        }
        
    }
  
    
    
    //MARK: - Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
