//
//  SignUpVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/2/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    var imageSelected = false
    
    let plusPhotoButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return textField
    }()
    
    let passwordTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
    }()
    let fullNameTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return textField
    }()
    
    let usernameTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return textField
    }()
    
    let signUpButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.backgroundColor = UIColor.init(red: 149/255, green: 205/255, blue: 244/255, alpha: 1)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let alreadyHaveAccountButton : UIButton = {
        
        let button = UIButton(type: .system)
        
        let attributeTitle = NSMutableAttributedString(string: "Already have an account  ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributeTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - INIT
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComplonets()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    //MARK: - Selector
    
    @objc func handleShowLogin()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp(){
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullName = fullNameTextField.text else {return}
        guard let username = usernameTextField.text?.lowercased() else { return}
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            // handle error
            if let error = error {
                print("Error signing up use : ",error.localizedDescription)
                return
            }
            
            // set profile image
            guard let profileImage = self.plusPhotoButton.imageView?.image else {return}
            
            // upload data
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else {return}

            
            //place Image in firebase Storage
            let fileName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
            
            Storage.storage().reference().child("profile_image").child(fileName).putData(uploadData, metadata: nil, completion: { (metaData, error) in
                
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
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    let dictionaryValues = ["profileImageURl":URL,"fullname":fullName,
                                            "username": username
                    ]
                    
                    
                    let values = [uid:dictionaryValues]
                    // Storing Data firebase user
                    Database.database().reference().child("User").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        print("Scucesss uploading data")
                        
                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return}
                        mainTabVC.configureViewController()
                        
                        // dissmiss Login VC
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                })
                
                
            })
        }
        
        
    }
    
    @objc func formValidation(){
        
        guard emailTextField.hasText, passwordTextField.hasText, usernameTextField.hasText,fullNameTextField.hasText,
            imageSelected == true
            else {
                
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = UIColor.init(red: 149/255, green: 205/255, blue: 244/255, alpha: 1)
                return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    @objc func handleSelectProfilePhoto(){
        // Configure Image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present image picker
        
        self.present(imagePicker,animated: true,completion: nil)
    }
    
    
    //MARK: - HelperFunction
    
    func configureViewComplonets (){
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,fullNameTextField,usernameTextField,passwordTextField,signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
        
    }
    
    // Image Picker Delegate function
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        // image selected  is true
        imageSelected = true
        
        // Configure plus photo Button
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
