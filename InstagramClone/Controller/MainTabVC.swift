//
//  MainTabVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/3/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController , UITabBarControllerDelegate{
    
    //MARK: - Properties
    
    let dot = UIView()
    var notificationIDs = [String]()
    
    
    
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        configureViewController()
        
        //configure navigation dot
        configureNotificationDot()
        
        // user Validation
        checkIfUserIsLoggedIn()
        
        //observe notification
        observeNotification()
        
        
    }
    
    //MARK: - Helper function
    
    func configureNotificationDot () {
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height == 2436 {
                // configure dot for iphone x
                
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
                
                
            }
            else {
                //configure dot for other devices
                
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            //create dot
            
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width/5)/2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width/2
            self.view.addSubview(dot)
            dot.isHidden = true
            
    
        }
        
    }
    
    
    // Function to create view controller
    
    func configureViewController(){
        
        // Home feed Controller
        
        let feedVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Search controller
        let searchVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
        
        // slect Post controller
        
//        let uploadPostVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
        
        let selectPhotVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        //notification Controller
        let notificationVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationVC())
        
        // Settings Controller
        
        let userProfileVC = constructNavController(unselectrdImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        
        
        // view controller added to tab VC
        
        viewControllers = [feedVC,searchVC,selectPhotVC,notificationVC,userProfileVC]
        // tab bar tint color
        
        tabBar.tintColor = .black
        
    }
    
    // Contruct Navigation controller
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // used first index of instead of index of
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            present(navController,animated: true,completion: nil)
            return false
        } else if index == 3 {
            dot.isHidden = true
//            setNotificationToSet()
            return true
        }
        return true
    }
    
    func constructNavController(unselectrdImage : UIImage, selectedImage : UIImage, rootViewController : UIViewController = UIViewController()) -> UINavigationController{
        
        
        // contruct nav Controller
        
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectrdImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        
        return navController
    }
    
    // Check if user is logged in
    
    func checkIfUserIsLoggedIn(){
        
        if Auth.auth().currentUser == nil {
            print("Curerent User is Nil")
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController,animated:  true,completion: nil)
                
            }
            return
            
        }
    }
    
    func observeNotification () {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        self.notificationIDs.removeAll()
        
        NOTIFICATION_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach({ (snapshot) in
                let notificationId = snapshot.key
                
                            NOTIFICATION_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
                                guard let checked = snapshot.value as? Int else {return}
                
                                if checked == 0 {
                                    self.dot.isHidden = false
//                                    self.notificationIDs.append(notificationId)
                
                                }else {
                                    self.dot.isHidden = true
                                }
                            })
            })
            

        }
        
    }
    
    
//    func setNotificationToSet (){
//
//         guard let currentUid = Auth.auth().currentUser?.uid else {return}
//
//        for notificationID in notificationIDs{
//
//        NOTIFICATION_REF.child(currentUid).child(notificationID).child("checked").setValue(1)
//        }
//    }
    
    
}
