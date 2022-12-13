//
//  UserApi.swift
//  SkateBud
//
//  Created by Victor on 2022-10-25.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD

class UserApi {
    
    var currentUserId: String {
//        if Auth.auth().currentUser != nil {
//            return Auth.auth().currentUser!.uid
//        } else {
//            return ""
//        }
        // refactored into
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            print(authData?.user.uid)
            onSuccess()
        }
    }
    
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        //Check if user selected an image
        guard let imageSelected = image else {
            ProgressHUD.showError(ERROR_EMPTY_PHOTO)
            return
        }
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else  {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password)
        { (authDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email,
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    STATUS: "Welcome to SkateBud"
                ]
                
                guard let imageSelected = image else {
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    return
                }
                
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
                
                let storageProfileRef = Ref().storageSpecificProfile(uid:authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict, onSuccess: {
                    onSuccess()
                }, onError: { (errorMessage) in
                    onError(errorMessage)
                })
                
            }
        }
    }
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues(dict) { (error, dataRef) in
            if error !=  nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    func logOut() {
        do {
            Api.User.isOnline(bool: false)
            try Auth.auth().signOut()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
        }
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.configureInitialViewController()
        }
    }
    
    func observeUsers(onSuccess: @escaping(UserCompletion)) {
        Ref().databaseUsers.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInforSingleEvent(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInfor(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    func isOnline(bool: Bool) {
        if !Api.User.currentUserId.isEmpty {
            let ref = Ref().databaseIsOnline(uid: Api.User.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String) {
        let ref = Ref().databaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "typing": to
        ]
        ref.updateChildValues(dict)
    }
}

typealias UserCompletion = (User) -> Void
