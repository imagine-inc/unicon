//
//  SetTeamImageViewController.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/18.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit

class SetTeamImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var teamImage: UIImage?
    
    @IBOutlet weak var imageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        guard let teamImage = teamImage else { print("please set team image"); return }
        SetTeamIntroViewController.teamImage = teamImage
        performSegue(withIdentifier: "ToNext", sender: nil)
        
    }
    
    @IBAction func pickImage(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ImagePicker", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "ImagePickerVC") as! CamerarollViewController
        newVC.from = self
        self.present(newVC, animated: true, completion: nil)
    }
    
    func updateImage(image: UIImage) {
        imageBtn.setTitle(nil, for: UIControlState())
        imageBtn.setImage(image, for: UIControlState())
    }

}
