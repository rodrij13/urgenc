//
//  ViewController.swift
//  UrgenC
//
//  Created by Juan Rodriguez on 10/3/17.
//  Copyright © 2017 Juan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "newMessageIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navContoller = UINavigationController(rootViewController: newMessageController)
        present(navContoller, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        //check if user is logged in
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            //fetch single item from database
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
                (snapshot) in
                //display item name in title
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
        
    }

    func handleLogout() {
        //signout user from firebase and return error if one occurs
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        //present the login view controller to handle logins and registration
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }

}
