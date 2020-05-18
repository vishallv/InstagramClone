//
//  NotificationVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let reuserIdentifier = "NotificationCell"

class NotificationVC: UITableViewController,NotificationCellDelegate {
  
    
    
    //MARK: - Prpoerties
    var notifications  = [Notification]()
    var timer : Timer?
    var currentKey : String?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //clear seperator line
        tableView.separatorColor = .clear
        
        //nav title
        navigationItem.title = "Notification"
        
        //register cell
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuserIdentifier)
        
        //fetch notication from server
        fetchNotifications()
        
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count > 2 {
            if indexPath.item == notifications.count - 1 {
                fetchNotifications()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! NotificationCell
        
        
       cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    //MARK: - Protocol from Notification cell
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else {return}
        
        if user.isFollowed {
            
            //handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
           
        }
        else {
            
            //handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
            
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else {return}
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = post
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    //MARRK: - Handlers
    
    func handleReloadTable (){
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotification), userInfo: nil, repeats: false)
    }
    
    @objc func handleSortNotification () {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }

    //MARK: - APLI call
    
    func fetNotifications(forNotificationId notificationID : String , forDataSnapshot snapshot : DataSnapshot){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}

        guard let dictionary  = snapshot.value as? Dictionary<String,AnyObject> else{return}
        guard let uid = dictionary["uid"]  as? String else {return}
        
        
        Database.fetchUser(with: uid, completion: { (user) in
            
            //notification for post
            if let posId = dictionary["postId"] as? String {
                
                Database.fetchPost(postId: posId, completion: { (post) in
                    
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    
                    self.handleReloadTable()
                    
                })
            }else {
                
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                
                self.handleReloadTable()
            }
        })
        
        NOTIFICATION_REF.child(currentUid).child(notificationID).child("checked").setValue(1)
    }
    
    func fetchNotifications (){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        if currentKey == nil{
            NOTIFICATION_REF.child(currentUid).queryLimited(toLast: 3).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                guard let allObejts = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObejts.forEach({ (snapshot) in
                   
                    let notificationID = snapshot.key
                    self.fetNotifications(forNotificationId: notificationID, forDataSnapshot: snapshot)
                    
                })
                
               self.currentKey = first.key
            }
            
        }else {
            
            NOTIFICATION_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return}
                guard let allObejts = snapshot.children.allObjects as? [DataSnapshot] else {return}
                
                allObejts.forEach({ (snapshot) in
                    
                    let notificationID = snapshot.key
              
                    if notificationID != self.currentKey{
                        self.fetNotifications(forNotificationId: notificationID, forDataSnapshot: snapshot)
                    }
                })
                
                self.currentKey = first.key
                
            }
            
            
        }
    }
 

}
