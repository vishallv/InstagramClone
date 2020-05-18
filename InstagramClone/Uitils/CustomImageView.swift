//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/11/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

var imageCache = [String:UIImage]()

class CustomImageView : UIImageView{
    
    var lastImageUsedToLoadUrl : String?
    
    
    func loadImage (with urlString : String)
    {
        
   
        
        self.image = nil
        
        //last image is
        lastImageUsedToLoadUrl = urlString
        
        //check if image exist in cache
        if let cachedImage = imageCache[urlString]{
            self.image = cachedImage
            return
        }
        
        //if image does not exist in cache
        
        guard let url = URL(string: urlString) else {return}
        
        // fetch content from url
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error to retrive image : ",error.localizedDescription)
            }
            
            if self.lastImageUsedToLoadUrl != url.absoluteString {
                return
            }
            // image data
            
            guard let imageData = data else {return}
            //set user image data
            let photoImage = UIImage(data: imageData)
            
            // set kay and value image
            imageCache[url.absoluteString] = photoImage
            
            //set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
            }.resume()
        
    }
}
