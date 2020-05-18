//
//  Protocols.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/6/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header:UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header : UserProfileHeader)
}

protocol FollowCellDelegate {
    func handleFollowTapped(for cell : FollowLikeCell)
    
}

protocol FeedCellDelegate {
    func handleUsernameTapped(for cell : FeedCell)
    func handleOptionTapped(for cell : FeedCell)
    func handleLikeTapped(for cell : FeedCell,isDoubleTap : Bool)
    func handleCommentTapped(for cell : FeedCell)
    func handleConfigureLikeButton (for cell : FeedCell)
    func handleShowLikes(for cell : FeedCell)
    
}

protocol NotificationCellDelegate {
    func handleFollowTapped (for cell : NotificationCell)
    func handlePostTapped (for cell : NotificationCell)
}

protocol Printable {
    var description : String { get }
}


protocol CommentInputAccessoryViewDelegate {
    
    func didSubmit(forComment comment : String)
}
