//
//  SetTeamIntroViewController.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/18.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit
import Firestore

class SetTeamIntroViewController: UIViewController, UITextViewDelegate {

    
    // heres are the data to create a team
    static var targetGender = String()
    static var teamName = String()
    static var teamImage = UIImage()
    
    var teamID = String()
    var imageUrlStr = String()
    
    @IBOutlet weak var hitokotoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hitokotoTextView.delegate = self
        hitokotoTextView.textContainerInset = UIEdgeInsetsMake(20, 30, 20, 30)
        hitokotoTextView.sizeToFit()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func nextBtnTapped(_ sender: Any) {
        
        guard let intro = hitokotoTextView.text, hitokotoTextView.text != "" else { print("please set intro"); return }
        
        TeamService.create(teamName: SetTeamIntroViewController.teamName, teamGender: "male", targetGender: SetTeamIntroViewController.targetGender, teamImage: SetTeamIntroViewController.teamImage, intro: intro) { team in
            if let team = team {
                self.teamID = team.teamID
                self.imageUrlStr = team.teamImageURL
                Team.setCurrent(team, writeToUserDefaults: true)
                self.performSegue(withIdentifier: "ToNext", sender: team)
            } else {
                print("失敗でごじゃる")
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToNext") {
            if let subVC: InviteMemberViewController = segue.destination as? InviteMemberViewController {
                subVC.teamID = self.teamID
                subVC.imageUrlStr = self.imageUrlStr
            }
        }
    }

}
