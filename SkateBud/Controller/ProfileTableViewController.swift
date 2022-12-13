//
//  ProfileTableViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-11-14.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var experienceSegment: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        observeData()
    }
    
    func setupView() {
        setupAvatar()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupAvatar() {
        avatar.layer.cornerRadius = 40
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker() {
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func observeData() {
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.statusTextField.text = user.status
            self.avatar.loadImage(user.profileImageUrl)
            
            if let age = user.age {
                self.ageTextField.text = "\(age)"
            } else {
                self.ageTextField.placeholder = "Optional"
            }
            
            if let experience = user.experience {
                if (experience == "Beginner") {
                    self.experienceSegment.selectedSegmentIndex = 0
                } else if (experience == "Intermediate") {
                    self.experienceSegment.selectedSegmentIndex = 1
                } else if (experience == "Advanced") {
                    self.experienceSegment.selectedSegmentIndex = 2
                }
            }
        }
    }

    @IBAction func logoutButtonDidTapped(_ sender: Any) {
        Api.User.logOut()
    }
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        ProgressHUD.show("Loading...")
        
        var dict = Dictionary<String, Any>()
        if let username = usernameTextField.text, !username.isEmpty {
            dict["username"] = username
        }
        if let email = emailTextField.text, !email.isEmpty {
            dict["email"] = email
        }
        if let status = statusTextField.text, !status.isEmpty {
            dict["status"] = status
        }
        if experienceSegment.selectedSegmentIndex == 0 {
            dict["experience"] = "Beginner"
        } else if experienceSegment.selectedSegmentIndex == 1 {
            dict["experience"] = "Intermediate"
        } else if experienceSegment.selectedSegmentIndex == 2 {
            dict["experience"] = "Advanced"
        }
        if let age = ageTextField.text, !age.isEmpty {
            dict["age"] = Int(age)
        }
        
        Api.User.saveUserProfile(dict: dict, onSuccess: {
            if let img = self.image {
                StorageService.savePhotoProfile(image: img, uid: Api.User.currentUserId, onSuccess: {
                    ProgressHUD.showSuccess()
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}

extension  ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            avatar.image = imageOriginal
        }
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = imageSelected
            avatar.image = imageSelected
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
