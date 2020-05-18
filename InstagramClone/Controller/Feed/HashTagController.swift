//
//  HashTagController.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/23/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

private let identifier = "HashTagCell"
class HashTagController : UICollectionViewController , UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    var posts = [Post]()
    var hashTag : String?
    
    //MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        //configure nav bar
        configureNavigationBar()
        
        //register cell
        collectionView.register(HashTagCell.self, forCellWithReuseIdentifier: identifier)
        fetchPost()
        
        
    }
    //MARK: - UicollectionViewFlowlayout
    
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
    
    //MARK: - UicollectionViewDatasource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! HashTagCell
        
        cell.post = posts[indexPath.row]
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    //MARK: - Helper function
    
    func configureNavigationBar(){
        
        guard let hashtag = self.hashTag else {return}
        navigationItem.title = hashtag
        
    }
    
    //MARK: - API call
    
    func fetchPost (){
        guard let hashtag = self.hashTag else {return}
        
        HASH_TAG_POST.child(hashtag).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(postId: postId, completion: { (post) in
                
                self.posts.append(post)
                self.collectionView.reloadData()
            })
            
            
        }
        
    }
    
}
