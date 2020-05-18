//
//  SearchVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuseidentifier = "SearchUserCell"
private let identifier = "SearchPostCell"

class SearchVC: UITableViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  
    
    
    var users = [User]()
    var filteredUsers = [User]()
    var seacrchBar = UISearchBar()
    var inSearchMode = false
    
    var posts = [Post]()
    
    var collectionView : UICollectionView!
    var collectionViewEnabled = true
    var currentKey : String?
    var userCurrentKey : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseidentifier)
        
        //confgure collection view
       configureCollectionView()
      
        
        //seperator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        //configure search bar
        configureSearchBar()
        
        //configure fresh
        configureRefreshControl()
        
        // fetch user
//        fetchUsers()
        
        //fetch posts
        fetchPost()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode{
            return filteredUsers.count
        }
        else {
        return users.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseidentifier, for: indexPath) as! SearchUserCell
        
        var user : User!
        
        if inSearchMode{
            user = filteredUsers[indexPath.row]
        }else {
            user = users[indexPath.row]
        }
        cell.user = user

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user : User!
        
        if inSearchMode{
         user = filteredUsers[indexPath.row]
        }
        else {
            user = users[indexPath.row]
        }
        
        // create instance of profile VC
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        //passes data to Profile view controller
        userProfileVC.user = user
        
        // Push View controller
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - UIColloectionView
    
    func configureCollectionView () {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - ((navigationController?.navigationBar.frame.height)!)-((tabBarController?.tabBar.frame.height)!))
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        tableView.addSubview(collectionView)
        
         collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: identifier)
        tableView.separatorColor = .clear
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 20 {
            
            if indexPath.item == posts.count - 1 {
                fetchPost()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-2) / 3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SearchPostCell
        
        cell.post = posts[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    //MARK: - Helper function
    
    
    
    func configureSearchBar() {
        
        seacrchBar.sizeToFit()
        seacrchBar.delegate = self
        navigationItem.titleView = seacrchBar
        seacrchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        seacrchBar.tintColor = .black
        
    }
    
    func configureRefreshControl (){
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh (){
        
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPost()
        collectionView.reloadData()
    }
    
    
    //MARK: - UISearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        seacrchBar.showsCancelButton = true
        //fetch user when begin editing
        fetchUsers()
        
        collectionView.isHidden = true
        collectionViewEnabled = false
        
        // set sperator color
        
        tableView.separatorColor = .lightGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //handle change in text
        
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            tableView.reloadData()
        }else {
            inSearchMode = true
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            tableView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        seacrchBar.endEditing(true)
        seacrchBar.showsCancelButton = false
        inSearchMode = false
        tableView.reloadData()
        seacrchBar.text = nil
        
        collectionViewEnabled = true
        collectionView.isHidden = false
        
        tableView.separatorColor = .clear
        
        tableView.reloadData()
    }
    //Fetch users
    
    func fetchUsers(){
        
        if userCurrentKey == nil{
        
        USER_REF.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in

            guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}

            allObjects.forEach({ (snapshot) in
                let uid = snapshot.key

                Database.fetchUser(with: uid, completion: { (user) in

                    self.users.append(user)
                    self.tableView.reloadData()
                })
            })
            self.userCurrentKey = first.key

            }}
        
        else {
            
            USER_REF.queryOrderedByKey().queryEnding(atValue: self.userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key
                    
                    if uid != self.userCurrentKey{
                    Database.fetchUser(with: uid, completion: { (user) in
                        
                        self.users.append(user)
                        self.tableView.reloadData()
                    })
                    }
                })
                self.userCurrentKey = first.key
                
            }
        }
        
        
//        Database.database().reference().child("User").observe(.childAdded) { (snapshot) in
//            //uid
//            let uid = snapshot.key
//
//
//            Database.fetchUser(with: uid, completion: { (user) in
//                self.users.append(user)
//                self.tableView.reloadData()
//            })
//
//        }
        
    }
    
    func fetchPost (){
        
        
        if currentKey == nil {
            
            POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value) { (snapshot) in
                
                self.tableView.refreshControl?.endRefreshing()
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    Database.fetchPost(postId: postId, completion: { (post) in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                    })
                })
                
                self.currentKey = first.key
            }
        }else {
            
            //paginate HEre
            
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else{return}
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey{
                    
                    Database.fetchPost(postId: postId, completion: { (post) in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                        
                    })
                    }
                })
                
                self.currentKey = first.key
                
            }
        }
        
        
//        posts.removeAll()
//
//        POSTS_REF.observe(.childAdded) { (snapshot) in
//
//            let postId = snapshot.key
//
//            Database.fetchPost(postId: postId, completion: { (post) in
//                self.posts.append(post)
//                self.collectionView.reloadData()
//
//            })
//
//        }
    }
    
    
    
    
}
