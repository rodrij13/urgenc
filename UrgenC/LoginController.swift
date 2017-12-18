//
//  LoginController.swift
//  UrgenC
//
//  Created by Juan Rodriguez on 10/3/17.
//  Copyright © 2017 Juan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["Login", "Register"])
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.tintColor = UIColor.white
        segControl.selectedSegmentIndex = 1
        segControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        return segControl
    }()
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)       //get title for selected seg
        loginRegisterButton.setTitle(title, for: .normal)           //change title of loginreg button
        //change height of input container view
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //change height of nametextfield
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        //change height of emailtextfield
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height of passwordtextfield
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ucLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    /*
     This function is used whenever the register/login button is pressed to either handle a login or handle a register
     */
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    /*
     Handles login with email and password registered into db
     */
    func handleLogin() {
        //unwrap text fields
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("Invalid Form")
                return
        }
        //sign in user with email and pw
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if let error = error {
                print(error)
                return
            }
            
            //dismiss login/reg view if successful
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    /*
     Registers user into firebase db
     */
    func handleRegister() {
        print("Register Pressed")
        //safely unwrap uitextfields
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Invalid Form")
                return
        }
        
        //auth user with email and pw
        Auth.auth().createUser(withEmail: email, password: password, completion: {( user: User?, error) in
            if let error = error {
                print(error)
                return
            }
            //successfully authd user
            
            //unwrap uid
            guard let uid = user?.uid else {
                return
            }
            
            //save user into database
            let ref = Database.database().reference(fromURL: "https://urgenc-8271f.firebaseio.com/")    //setup ref to my db
            let usersRef = ref.child("users").child(uid)        //create ref for users, with children users and uid
            let values = ["email": email, "name": name]         //create dictionary from email and name input
            usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in      //input values into user ref
                if let err = err {
                    print(err)
                    return
                }
                self.dismiss(animated: true, completion: nil)                //successfully saved user into database, dismiss login viewcontroller
            })
            
        })
    }
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true      //masked text when entering pw
        
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(logoImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupContainerView()
        setupLoginRegButton()
        setupProfileImageView()
        setupSegControl()

    }
    
    func setupSegControl() {
        //setup constraints for segmented control button w/autolayout
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    }
    
    func setupProfileImageView() {
        //setup autolayout for image
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    func setupLoginRegButton() {
        //add autolayoout constraints for login button
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?        //declare optional for height anchor, used for toggling
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupContainerView() {
        //add autolayout to input container
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)         //set the height anchor to the inputs cont. view h anchor
        inputsContainerViewHeightAnchor?.isActive = true        //make it active
        
        //addsubview within the inputs container and set constraints
        inputsContainerView.addSubview(nameTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //addsubview and set constraints for name separator
        inputsContainerView.addSubview(nameSeparatorView)
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //add subviews and set constraints for email text field
        inputsContainerView.addSubview(emailTextField)
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //add subview and constraints for email separator
        inputsContainerView.addSubview(emailSeparatorView)
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //add subviews and set constraints for password text field
        inputsContainerView.addSubview(passwordTextField)
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    //change status bar to light color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


//extension to UIColor for easier rgb inputs
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
