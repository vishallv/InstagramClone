//
//  CommentInputTextView.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 8/1/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {

    //MARK: - Properties
    let placeHolder : UILabel = {
        
        let label = UILabel()
        label.text = "Enter Comment"
        label.textColor = .lightGray
        return label
    }()
 

    //MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeHolder)
        placeHolder.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        placeHolder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Handler
    
    @objc func handleTextChange (){
        
        placeHolder.isHidden = !self.text.isEmpty
    }
    
}
