//
//  NewMessageController.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/21/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessageController : UITableViewController{
    
    //MARK: - Properties
    var users = [User]()
    var messageController : MessagesCOntroller?
    
    //MARK: -Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call navigation bar function
        configureNavigationBar()
        
        //register cell
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //fetch users
        fetchUsers()
        
    }
    
    //MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            
         let user = self.users[indexPath.row]

                self.messageController?.showChatController(forUser: user)
            
          
           
        }
        
    }
    
    
    //MARK: - Handler
    
    @objc func handleCancelTapped () {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Helper Function
    
    func configureNavigationBar () {
        
        navigationItem.title = "New Messages"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
    }
    
    //MARK: - API Call
    
    func fetchUsers () {
        guard let currentuid = Auth.auth().currentUser?.uid else {return}
        
        
        USER_REF.observe(.childAdded) { (snapshot) in
            
            let uid = snapshot.key
            if currentuid != uid {
                
                Database.fetchUser(with: uid, completion: { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }

        }
    }
    
}

