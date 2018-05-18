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
    /*
     *  FIELDS
    */
    let cellId = "cellId"
    var loggedinUser = User()
    var messages = [Message]()
    
    /*
     *  METHODS
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "newMessageIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkIfUserIsLoggedIn()
    }
    
    func loadMessages() {
        Database.database().reference().child("messages").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let msg = Message()
                msg.setValuesForKeys(dictionary)
                self.messages.append(msg)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        self.navigationController?.pushViewController(newMessageController, animated: true)
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
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.loggedinUser.name = dictionary["name"] as? String
                    self.loggedinUser.uid = snapshot.key
                    self.loggedinUser.email = dictionary["email"] as? String
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let msg = messages[indexPath.row]
        cell.textLabel?.text = msg.text
        //cell.detailTextLabel?.text = msg.timeStamp
        return cell
    }
}
