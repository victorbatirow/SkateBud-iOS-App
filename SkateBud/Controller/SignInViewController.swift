//
//  SignInViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-10-24.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        setupTitleLabel()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
        
    }

    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateFields()
        self.signIn(onSuccess: {
            // set status  to online after user sign in
            Api.User.isOnline(bool: true)
            // user succesfully logged in. Switch to main tabbar view
            (self.view.window?.windowScene?.delegate as! SceneDelegate).configureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}
