//
//  ChatController.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/21/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController : UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    //MARK: - Properties
    
    var user : User?
    var messages = [Message]()
    
    lazy var containerView : UIView = {
        
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
        
        
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 50, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(messageTexField)
        messageTexField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .lightGray
        
        
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        containerView.backgroundColor = .white
        return containerView
    }()
    
    let messageTexField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Message.."
        return tf
    }()
    let sendButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - INit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //configure navigation bar
        configureNavigationBar()
        
        //set background color to white
        collectionView.backgroundColor = .white
        
        //fertch message from database
        
        observeMessages()
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
    
    //MARK: - Collectionview
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        var height : CGFloat = 80
        let message = messages[indexPath.row]
        
        height = estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.message = messages[indexPath.row]
        
        configureMessage(cell: cell, message: messages[indexPath.row])
        return cell
        
    }
    
    
    
    
    
    //MARK: - Handlers
    
    @objc func handleSend(){
        uploadMessageToServer()
        
        messageTexField.text = nil
    }
    @objc func handleInfoPressed (){
        guard let user = self.user else {return}
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
     
    }
    
    func configureNavigationBar (){
        guard let user = self.user else {return}
        navigationItem.title = user.username
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoPressed), for: .touchUpInside)
        
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = infoBarButtonItem
        tabBarController?.tabBar.isHidden = true
        
    }
    
    func estimateFrameForText (_ Text : String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: Text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureMessage (cell:ChatCell , message : Message){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
        }else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            
        }
        
        
    }
    
    //MARK: = API call
    
    func uploadMessageToServer () {
        
        guard let messageText = messageTexField.text else {return}
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let user = self.user else {return}
        guard let uid = user.uid else {return}
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValues = ["creationDate":creationDate,
                             "fromId":currentUid,
                             "toId":uid,
                             "messageText":messageText] as [String:Any]
        
        
        let messageRef = MESSAGES_REF.childByAutoId()
        messageRef.updateChildValues(messageValues)
        
        guard let ref  = messageRef.key else {return}
        USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([ref:1])
        USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([ref:1])
        
        
    }
    
    
    func observeMessages () {
    
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let chatPartnerId = self.user?.uid else {return}
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
           
            let messageId = snapshot.key
            
            self.fetchMessage(withmessageId: messageId)
            
        }

    }
    
    func fetchMessage (withmessageId messageId : String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard  let dictionary = snapshot.value as? Dictionary<String,AnyObject> else {return}
            let message = Message(dictionary: dictionary)
            
            self.messages.append(message)
            self.collectionView.reloadData()
            
        }
        
        
    }
    
    
}
