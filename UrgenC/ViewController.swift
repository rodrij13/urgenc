//
//  ViewController.swift
//  UrgenC
//
//  Created by Juan Rodriguez on 10/3/17.
//  Copyright © 2017 Juan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //check if user is logged in
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
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
