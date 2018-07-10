//
//  ChatViewController.swift
//  unicon
//
//  Created by yo hanashima on 2018/06/24.
//  Copyright © 2018 Imajin Kawabe. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITableViewDelegate {
    
    var groupChats = [Team]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        
        self.navigationItem.hidesBackButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "ChatListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatListCell")
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.duration = 0.5
        self.navigationController!.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToSingleChat", sender: nil)
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListTableViewCell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
}

