//
//  ViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-10-24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var signInGoogleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Simulate a touch on the createAccountButton
        createAccountButton.sendActions(for: .touchUpInside)
    }
    
    
    
    func setupUI() {
        setupHeaderTitle()
        setupOrLabel()
        setupTermsLabel()
        setupFacebookButton()
        setupGoogleButton()
        setupCreateAccountButton()
    }


}

