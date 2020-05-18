//
//  LoginVC.swift
//  InstagramClone
//
//  Created by Vishal Lakshminarayanappa on 7/2/19.
//  Copyright © 2019 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    //MARK: - Properties
    
    let logoImageContainer : UIView = {
        
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        
        return view
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
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return textField
    }()
    
    let loginButton : UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.init(red: 149/255, green: 205/255, blue: 244/255, alpha: 1)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let dontHaveAccountButton : UIButton = {
        
        let button = UIButton(type: .system)
        
        let attributeTitle = NSMutableAttributedString(string: "Don't have an account  ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributeTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Hide navigation bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageContainer)
        logoImageContainer.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        configureViewComplonets()
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
    }
    
    //MARK: - Selector
    @objc func handleShowSignUp(){
        let signUp = SignUpVC()
        navigationController?.pushViewController(signUp, animated: true)
        
      
    }
    @objc func handleLogin(){
        
       
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print("Unable to sign user in", error.localizedDescription)
                return
            }
            // handle success
            
            print("Succesfull Login")
            
//            let mainTabVC = MainTabVC()
//            self.present(mainTabVC,animated: true,completion: nil)
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return}
            mainTabVC.configureViewController()
            
            // dissmiss Login VC
            self.dismiss(animated: true, completion: nil)
            
            
        }
        
        // Sign User in to
        
    }
    @objc func formValidation(){
        
        guard emailTextField.hasText, passwordTextField.hasText
            else{
                
                loginButton.backgroundColor = UIColor.init(red: 149/255, green: 205/255, blue: 244/255, alpha: 1)
                loginButton.isEnabled = false
                return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor.init(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    //MARK: - Helper Function
    
    func configureViewComplonets (){
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoImageContainer.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
        
    }
    
    
    
}
