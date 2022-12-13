//
//  ViewController+UI.swift
//  SkateBud
//
//  Created by Victor on 2022-10-24.
//

import UIKit

extension ViewController {
    
    func setupHeaderTitle() {
        let title = "Create a new account"
        let subTitle = "\n\nLorem ipsum dolor sit amet conse ctetur adipiscing elit swd do."
        
        let attributedText = NSMutableAttributedString(string: title, attributes:
            [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
             NSAttributedString.Key.foregroundColor: UIColor.black
            ])
        let attributedSubTitle = NSMutableAttributedString(string: subTitle, attributes:
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.45)
            ])
        attributedText.append(attributedSubTitle)
        
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attributedText
    }
    
    func setupOrLabel() {
        orLabel .text = "Or"
        orLabel.font =  UIFont.boldSystemFont(ofSize: 16)
        orLabel.textColor = UIColor(white: 0, alpha: 0.45)
        orLabel.textAlignment = .center
    }
    
    func setupTermsLabel() {
        let attributedTermsText = NSMutableAttributedString(string: "By clicking \"Create a new account\" you agree to our ", attributes:
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
             NSAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.65)
            ])
        
        let attributedSubTermsText = NSMutableAttributedString(string: "Terms of Service.", attributes:
            [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
             NSAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.65)
            ])
        attributedTermsText.append(attributedSubTermsText)
        
        termsOfServiceLabel.attributedText = attributedTermsText
        termsOfServiceLabel.numberOfLines = 0
    }
    
    func setupFacebookButton() {
        signInFacebookButton.setTitle("Sign in with Facebook", for: UIControl.State.normal)
        signInFacebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInFacebookButton.backgroundColor =  UIColor(red: 58/255, green: 85/255, blue: 159/255, alpha: 1)
        signInFacebookButton.layer.cornerRadius = 5
        signInFacebookButton.clipsToBounds = true
        
//        signInFacebookButton.setImage(UIImage(named:"facebookIcon"), for: UIControl.State.normal)
//        signInFacebookButton.imageView?.contentMode = .scaleAspectFit // fail
//        signInFacebookButton.tintColor = .white // fail
//        signInFacebookButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0) // fail
    }
    
    func setupGoogleButton() {
        signInGoogleButton.setTitle("Sign in with Google", for: UIControl.State.normal)
        signInGoogleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInGoogleButton.backgroundColor =  UIColor(red: 223/255, green: 74/255, blue: 50/255, alpha: 1)
        signInGoogleButton.layer.cornerRadius = 5
        signInGoogleButton.clipsToBounds = true
        
//        signInGoogleButton.setImage(UIImage(named:"googleIcon"), for: UIControl.State.normal)
//        signInGoogleButton.imageView?.contentMode = .scaleAspectFit // fail
//        signInGoogleButton.tintColor = .white // fail
//        signInGoogleButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0) // fail
    }
    
    func setupCreateAccountButton() {
        createAccountButton.setTitle("Create a new account", for: UIControl.State.normal)
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        createAccountButton.backgroundColor =  UIColor.black
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.clipsToBounds = true
    }
}
