//
//  HomeViewController.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/17.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import AlamofireImage
import BubbleTransition

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate, UITextViewDelegate {
    var window: UIWindow?
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamIntroTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnForMyProfile: UIButton!
    @IBOutlet weak var btnForMyProfileView: UIView!
    
    
    var teams = [Team]()
    var members = [User]()
    let transition = BubbleTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamIntroTextView.delegate = self
        teamIntroTextView.textContainerInset = UIEdgeInsetsMake(20, 30, 20, 30)
        teamIntroTextView.sizeToFit()
        
        self.navigationItem.hidesBackButton = true
        teamImageView.layer.cornerRadius = 80
        teamImageView.layer.masksToBounds = true
        
        let nib: UINib = UINib(nibName: "TeamCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TeamCell")
        collectionView.reloadData()
        
        btnForMyProfileView.learningAndLeading()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("呼ばれてる")
        getCurrentTeam()
    }
    
    @IBAction func goMatch(_ sender: Any) {
        
        goBack()

    }
    
    //    @IBAction func logOut(_ sender: Any) {
    //        let firebaseAuth = Auth.auth()
    //        do {
    //            try firebaseAuth.signOut()
    //
    //            let storyboard: UIStoryboard = UIStoryboard(name: "Onboard", bundle: nil)
    //            let newVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
    //            self.present(newVC, animated: true, completion: nil)
    //
    //        } catch let signOutError as NSError {
    //            print ("Error signing out: %@", signOutError)
    //        }
    //
    //    }
    
    
    func goBack() {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.duration = 0.5
        self.navigationController!.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func getCurrentTeam() {
        if let team = Team.current {
            
            if let url = URL(string: team.teamImageURL) {
                teamImageView.af_setImage(
                    withURL: url,
                    imageTransition: .crossDissolve(0.5)
                )
            }
            
            teamNameLabel.text = team.teamName
            teamIntroTextView.text = team.intro
            
            getTeamMembers(teamUID: team.teamID)
            
        }
        
    }
    
    func getTeamMembers(teamUID: String) {
        TeamService.getTeamMembers(teamUID: teamUID, completion: { members in
            if let members = members {
                self.members = members
                self.collectionView.reloadData()
            }
        })
    }
    
    
    // FOR COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCell", for: indexPath as IndexPath) as! TeamCollectionViewCell
        let member = members[indexPath.row]
        if let imageUrl = URL(string: member.userImage) {
            cell.memberImageView.af_setImage(
                withURL: imageUrl,
                imageTransition: .crossDissolve(0.5)
            )
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = btnForMyProfileView.center
        transition.bubbleColor = UIColor.hex(hex: "ffcc33", alpha: 1.0)
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = btnForMyProfileView.center
        transition.bubbleColor = UIColor.hex(hex: "ffcc33", alpha: 1.0)
        return transition
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ToMyProfile":
            let controller = segue.destination
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
        default:
            return
        }
    }
    
    @IBAction func goMyProfile(_ sender: Any) {
        performSegue(withIdentifier: "ToMyProfile", sender: nil)
    }
    
    
    @IBAction func addTeam(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Onboard", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "CreateOrJoinVC")
        self.present(newVC, animated: true, completion: nil)
    }
    
    
}


