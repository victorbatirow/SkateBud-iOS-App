//
//  SignUpViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-10-24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD
import CoreLocation
import GeoFire

class SignUpViewController: UIViewController {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullNameContainerView: UIView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        setupUI()
    }
    
    func setupUI() {
        setupTitleLabel()
        setupAvatar()
        setupFullNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateFields()
        
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String,
           let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            self.userLat = userLat
            self.userLong = userLong
        }
        self.signUp(onSuccess: {
            if !self.userLat.isEmpty && !self.userLong.isEmpty {
                let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                self.geoFireRef = Ref().databaseGeo
                self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
                    // send location to firebase
            }
            // set status  to online after user sign up
            Api.User.isOnline(bool: true)
            // user succesfully signed up. Switch to main tabbar view
            (self.view.window?.windowScene?.delegate as! SceneDelegate).configureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
    }
}
