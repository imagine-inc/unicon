//
//  UserService.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/21.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import Firestore
import Firestore.FIRDocumentSnapshot

typealias FIRUser = FirebaseAuth.User

struct UserService {
    
    static func signIn(_ firUser: FIRUser, firstName: String, userImage: URL, facebookID: String,  completion: @escaping (User?) -> Void) {
        
        let userImage = userImage.absoluteString
        
        // gender, age, area に関してはFacebookのアプリレビューが必要ならしいからとりあえずやめておいた。
        let userAttrs = ["firstName": firstName, "userImage": userImage, "userUID": firUser.uid, "facebookID": facebookID, "age": 20, "area": "Tokyo", "gender": "male"] as [String : Any]
        
        let ref = Firestore.firestore().collection("users").document(firUser.uid)
        
        
        ref.setData(userAttrs, options: SetOptions.merge()) { error in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.getDocument() { (document, err) in
                if let document = document {
                    print("Document data: \(document.data())")
                    if let user = User(document: document) {
                        print("User created")
                        completion(user)
                    }
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
    
    static func addPushID(userUID: String, pushID: String, success: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("users").document(userUID).setData(["pushID": pushID], options: SetOptions.merge()) {
            err in
            if let err = err {
                print(err.localizedDescription)
                return success(false)
            } else {
                success(true)
            }
        }
    }
    
    static func join(teamID: String, createdBy: String , success: @escaping (Bool) -> Void) {
        let rootRef = Firestore.firestore()
        let teamRef = rootRef.collection("teams").document(teamID).collection("members").document(createdBy)
        let userRef = rootRef.collection("users").document(createdBy)
        
        // First, get the user data
        userRef.getDocument() { (doc, err) in
            if let doc = doc {
                if let user = User(document: doc), let facebookID = user.facebookID {
                    let userDict = [
                        "firstName": user.firstName, "userImage": user.userImage, "userUID": createdBy, "facebookID": facebookID, "age": 20, "area": "Tokyo", "gender": "male"] as [String : Any
                    ]
                    
                    teamRef.setData(userDict, options: SetOptions.merge()) {err in
                        if let err = err {
                            print("error occured: \(err.localizedDescription)")
                            return success(false)
                        } else {
                            return success(true)
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    
    
    
}