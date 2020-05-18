//
//  SelectImageVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/8/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC : UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    //MARK: - Properties
    var images = [UIImage]()
    var asset = [PHAsset]()
    var selectedImage : UIImage?
    var header : SelectPhotoHeader?
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.backgroundColor = .white
        configureNavBarButton()
        
        // fetch photo
        fetchPhoto()
    }
    
    //MARK: - UIcollectionViewflowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 )/4
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: - UIcollectioviewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        self.header = header
        
        if let selectedImage = self.selectedImage{
            
            if let index = self.images.firstIndex(of: selectedImage){

                //asset associated with selected inmage

                let selectedAsset = self.asset[index]

                //image manger request
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)


                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in

                    header.photoImageView.image = image
                }

            }
            
//            header.photoImageView.image = selectedImage
        }
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        
        let image = images[indexPath.row]
        cell.photoImageView.image = image
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    //MARK: Handlers
    
    @objc func  handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleNext(){
       
        
        let uploadPostVC = UploadPostVC()
        uploadPostVC.selectectImage = header?.photoImageView.image
        uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 0)
        navigationController?.pushViewController(uploadPostVC, animated: true)
        
        
        
    }
    
    func configureNavBarButton (){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    
    func getAssetFetchOption() -> PHFetchOptions{
        
         let option = PHFetchOptions()
        //set fetch limit
        
        option.fetchLimit = 30
        
        //sort by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        // set sort descriptot for option
        option.sortDescriptors = [sortDescriptor]
        
        return option
        
    }
    
    func fetchPhoto(){
       
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOption())
        
        //fetch photo in background thread
        
        print("function running")
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in

                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                //request image representation for assest
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image{
                        //append image to data source
                        self.images.append(image)
                        
                        //apped asset to data source
                        self.asset.append(asset)
                        
                        //set selected image
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        // reload collection view with image count completed
                        
                        if count == allPhotos.count - 1 {
                            //reload collection view in main thread
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        
                        }
                        
                    }
                })
            })
        }
        
    }
}
