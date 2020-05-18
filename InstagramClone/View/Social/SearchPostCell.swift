//
//  SearchPostCell.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/20/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class SearchPostCell: UICollectionViewCell {
    
    //MARK: - Properties
    var post : Post? {
        didSet{
            //print("did set post")
            guard  let imageUrl = post?.imageUrl else {return}
            photoImageView.loadImage(with: imageUrl)
            
        }
    }
    
    let photoImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - INit
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
