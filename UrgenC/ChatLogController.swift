//
//  ChatLogController.swift
//  UrgenC
//
//  Created by Juan Rodriguez on 5/14/18.
//  Copyright © 2018 Juan Rodriguez. All rights reserved.
//
import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate {
    /*
     *  FIELDS
     */
    let cellId = "cellId"
    var receivingUser = User()
    var messages = [Message]()
    
    /*
     *  UI
     */
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /*
     *  METHODS
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = receivingUser.name
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        collectionView?.backgroundColor = UIColor.white
        setupComponents()
    }
    
    func setupComponents() {
        view.addSubview(containerView)

        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        view.addSubview(tableView)
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    }
    
    func handleSend() {
        // Get sender info
        guard let sendingUser = Auth.auth().currentUser
            else {
                print("no user signed in")
                return
        }
        
        // Ref db and unwrap textView
        let msgRef = Database.database().reference().child("messages").childByAutoId()
        guard let msgText = inputTextField.text
            else {
                print("invalid message text")
                return
        }
        
        // Send if not empty
        if (!msgText.isEmpty) {
            // Add to messages tree
            let timeStamp = NSDate().timeIntervalSince1970
            let values = [
                "text": msgText as NSObject,
                "fromUid": sendingUser.uid as NSObject,
                "toUid": receivingUser.uid! as NSObject,
                "timeStamp": timeStamp
                ] as [String : Any]
            msgRef.updateChildValues(values)
            self.navigationController!.popToRootViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Attention", message: "Message is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        inputTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
