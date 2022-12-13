//
//  ChatViewController.swift
//  SkateBud
//
//  Created by Victor on 2022-10-27.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ChatViewController: UIViewController {

    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var imagePartner: UIImage!
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height:36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var partnerId: String!
    var partnerUser: User!
    var placeholderLabel = UILabel()
    var picker = UIImagePickerController()
    var messages = [Message]()
    var isActive = false
    var lastTimeOnline = ""
    var isTyping = false
    var timer = Timer()
    var refreshControl = UIRefreshControl()
    var lastMessageKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        setupInputContainer()
        setupNavigationBar()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func sendButtonDidTapped(_ sender: Any) {
        if let text = inputTextView.text, text != "" {
            inputTextView.text = ""
            self.textViewDidChange(inputTextView)
            sendToFirebase(dict: ["text": text as Any])
        }
    }
    
    @IBAction func mediaButtonDidTapped(_ sender: Any) {
        // Create alert
        let alert = UIAlertController(title: "SkateBud", message: "Select source", preferredStyle: UIAlertController.Style.actionSheet)
        
        // Create alert action: camera
        let camera = UIAlertAction(title: "Take a Picture", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        // Create alert action: library
        let library = UIAlertAction(title: "Choose an Image or a Video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes =  [String(kUTTypeImage), String(kUTTypeMovie)]
                
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        // Create alert action: video camera
        let videoCamera = UIAlertAction(title: "Take a Video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        // Create alert action: cancel
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        // Add actionds to alert
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        alert.addAction(videoCamera)
        
        //present the alert
        present(alert, animated: true, completion: nil)
    }

}
