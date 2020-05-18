//
//  EditProfileController.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/31/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase


class EditProfileController : UIViewController{
    
    //MARK: - Properties
    
    var user : User?
    var imageChanged = false
    var usernameChanged = false
    var userProfileController : UserProfileVC?
    var updatedUsername : String?
    
    
    let profileImageView : CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let changePhotoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        
        return button
    }()
    
    let seperatorView : UIView = {
        let sepView = UIView()
        
        sepView.backgroundColor = .darkGray
        return sepView
    }()
    
    let usernameTextField : UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        return tf
    }()
    let fullNameTextField : UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.isUserInteractionEnabled = false
        tf.borderStyle = .none
        return tf
    }()
    
    let fullnameLabel  : UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let usernameLabel  : UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let usernameSeperatorView : UIView = {
        let sepView = UIView()
        
        sepView.backgroundColor = .darkGray
        return sepView
    }()
    
    let fullnameSeperatorView : UIView = {
        let sepView = UIView()
        
        sepView.backgroundColor = .darkGray
        return sepView
    }()
    
    //MARK: - INit
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // configure navigation bar
        configureNavigationBar()
        
        //configure container view
        configureContainerView()
        loadUserData()
        
        usernameTextField.delegate = self
    }
    
    //MARK: - HAndlers

    @objc func handleChangeProfilePhoto (){
       let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController,animated: true,completion: nil)
    }
    
    @objc func handleDone (){
       view.endEditing(true)
        
        if imageChanged{
            updateProfileImage()
        }
        if usernameChanged{
            updateUsername()
        }
    }
    
    @objc func handleCancel (){
        dismiss(animated: true, completion: nil)
    }
    
    func loadUserData (){
        
        guard let  user = self.user else {return}
        guard let imageUrl = user.profileImageUrl else {return}
        
        profileImageView.loadImage(with: imageUrl)
        fullNameTextField.text = user.name
        usernameTextField.text = user.username
        
    }
    
    func configureContainerView (){
        
         view.backgroundColor = .white
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150)
        
        let containerView  = UIView(frame: frame)
        containerView.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(containerView)
        
        let dimension: CGFloat  = 80
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
       
        profileImageView.layer.cornerRadius = dimension/2
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(changePhotoButton)
        
        changePhotoButton.anchor(top:profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(fullNameTextField)
        fullNameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: fullNameTextField.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        view.addSubview(fullnameSeperatorView)
        fullnameSeperatorView.anchor(top: nil, left: fullNameTextField.leftAnchor, bottom: fullNameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        
        view.addSubview(usernameSeperatorView)
        usernameSeperatorView.anchor(top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        
    }
    
    func configureNavigationBar(){
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
    }
    //MARK: - API calls
    
    func updateUsername (){
        
        guard let updatedUsername = self.updatedUsername else {return}
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard usernameChanged == true else{return}
        
        USER_REF.child(currentUid).child("username").setValue(updatedUsername) { (err, ref) in
            if let error = err {
                print("unable to change user name ",error.localizedDescription)
            }
            
            guard let userProfileVC = self.userProfileController else {return}
            userProfileVC.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    func updateProfileImage (){
        
        
        guard imageChanged == true else {return}
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let user = self.user else {return}
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
        
        let fileName = NSUUID().uuidString
        
        guard let updatedProfileImage = profileImageView.image else {return}
        
        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else {return}
        
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        Storage.storage().reference().child("profile_image").child(fileName).putData(imageData, metadata: nil, completion: { (metaData, error) in
            
            // Handle Error
            
            if let error = error {
                print("Failed top upload profile picture to firebase : ",error.localizedDescription)
            }
            
            //success upload Profile picture
            //                guard let profileImageURl = metaData?.downloadURL()?.absoluteString else {return}
            var URL : String?
            storageRef.downloadURL(completion: { (url, error) in
                if let error  = error {
                    print("Unable to get URl" , error.localizedDescription)
                    return
                }
                URL = url?.absoluteString
         
                USER_REF.child(currentUid).child("profileImageURl").setValue(URL, withCompletionBlock: { (err, ref) in
                    
                    guard let userProfileVC = self.userProfileController else {return}
                    userProfileVC.fetchCurrentUserData()
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
            })
            
            
        })
    }
    
    
}
extension EditProfileController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profileImageView.image = selectedImage
            self.imageChanged = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let user = self.user else {return}
        
        let trimmedString = usernameTextField.text?.replacingOccurrences(of: "\\s+$", with: "",options: .regularExpression)
        guard user.username != trimmedString else {
            print("Error: username was not changed")
            usernameChanged = false
            return
        }
        guard trimmedString != "" else {
            print("Error: Enter valid username")
            usernameChanged = false

            return
        }
        
        self.updatedUsername = trimmedString?.lowercased()
        usernameChanged = true
    }
}
