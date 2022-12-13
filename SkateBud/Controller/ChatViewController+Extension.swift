//
//  ChatViewController+Extension.swift
//  SkateBud
//
//  Created by Victor on 2022-11-10.
//

import Foundation
import UIKit

extension ChatViewController {
    func observeMessages() {
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
    }
    
    func sortMessages() {
        messages =  messages.sorted(by: { $0.date < $1.date })
        lastMessageKey = messages.first!.id
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let index = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: false)
        }
    }
    
    func setupPicker() {
        picker.delegate = self
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
    }
    
    @objc func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            Api.Message.loadMore(lastMessageKey: self.lastMessageKey, from: Api.User.currentUserId, to: self.partnerId, onSuccess: { (messagesArray, lastMessageKey) in
                if messagesArray.isEmpty {
                    self.refreshControl.endRefreshing()
                    return
                }
                self.messages.append(contentsOf: messagesArray)
                self.messages = self.messages.sorted(by: { $0.date < $1.date })
                self.lastMessageKey = lastMessageKey
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    func setupInputContainer() {
        let mediaImg = UIImage(named: "attachment_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mediaButton.setImage(mediaImg, for: UIControl.State.normal)
        mediaButton.tintColor = .lightGray
        
        let micImg = UIImage(named: "microphone_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        audioButton.setImage(micImg, for: UIControl.State.normal)
        audioButton.tintColor = .lightGray
        
        setupInputTextView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    @objc  func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            if #available(iOS 11.0, *) {
                bottomConstraint.constant = -keyboardViewEndFrame.height + view.safeAreaInsets.bottom
            } else {
                bottomConstraint.constant = -keyboardViewEndFrame.height
            }
        }
        
        view.layoutIfNeeded()
    }
    
    func setupInputTextView() {
       
        inputTextView.delegate = self
        
        placeholderLabel.isHidden = false
        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        let placeholderFontSize = self.view.frame.size.width / 25
        
        placeholderLabel.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        placeholderLabel.text = "Write a message"
        placeholderLabel.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.textAlignment = .left
        
        inputTextView.addSubview(placeholderLabel)
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        let containView = UIView(frame: CGRect(x: 0, y:  0, width: 36, height: 36))
        avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        tapRecognition(image: avatarImageView)
        containView.addSubview(avatarImageView)
        
        if imagePartner != nil {
            avatarImageView.image = imagePartner
            self.observeActivity()
            self.observeMessages()
        } else {
            avatarImageView.loadImage(partnerUser.profileImageUrl) { (image) in
                self.imagePartner = image
                self.observeActivity()
                self.observeMessages()
            }
        }
        
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        updateTopLabel(bool: false)
        
        self.navigationItem.titleView = topLabel
    }
    
    func tapRecognition(image: UIImageView) {
        image.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        image.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func imageViewTapped(imageView: UIImageView) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
        detailVC.user = partnerUser

        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func updateTopLabel(bool: Bool) {
        var status =  ""
        var  color = UIColor()
        if bool {
            status = "Active"
            color = UIColor.green
            if isTyping {
                status = "Typing..."
                color = UIColor.gray
            }
        } else {
            status  = "Last active " + self.lastTimeOnline
            color = UIColor.red
        }
        
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        
        let attributed = NSMutableAttributedString(string: partnerUsername + "\n" , attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.black])
        
        attributed.append(NSAttributedString(string: status, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: color]))
        topLabel.attributedText = attributed
    }
    
    func observeActivity() {
        let ref = Ref().databaseIsOnline(uid: partnerUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.isActive = active
                }
                if let latest = snap["latest"] as? Double {
                    self.lastTimeOnline = latest.convertDate()
                }
            }
            self.updateTopLabel(bool: self.isActive)
        }
        ref.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.isActive = snap as! Bool
                }
                if snapshot.key == "latest" {
                    let latest = snap as! Double
                    self.lastTimeOnline = latest.convertDate()
                }
                if snapshot.key == "typing" {
                    let typing = snap as! String
                    self.isTyping = typing == Api.User.currentUserId ? true : false
                }
                    
                self.updateTopLabel(bool: self.isActive)
            }
        }
    }
    
    func sendToFirebase(dict: Dictionary<String, Any>) {
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] = Api.User.currentUserId
        value["to"] = partnerId
        value["date"] = date
        value["read"] = true
        
        Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            let text = textView.text.trimmingCharacters(in: spacing)
            sendButton.isEnabled = true
            sendButton.setTitleColor(.black, for: UIControl.State.normal)
            placeholderLabel.isHidden = true
        } else {
            sendButton.isEnabled = false
            sendButton.setTitleColor(.lightGray, for: UIControl.State.normal)
            placeholderLabel.isHidden = false
        }
        
        if !isTyping {
            Api.User.typing(from: Api.User.currentUserId, to: partnerUser.uid)
            isTyping = true
        } else {
            timer.invalidate()
        }
        
        timerTyping()
    }
    
    func timerTyping() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (t) in
            Api.User.typing(from: Api.User.currentUserId, to: "")
            self.isTyping = false
        })
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl  = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl)
        } else {
            handleImageSelectedForInfo(info)
        }
    }
    
    func handleVideoSelectedForUrl(_ url: URL) {
        // save video data
        let videoName = NSUUID().uuidString
        StorageService.saveVideoMessage(url: url, id: videoName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = imageOriginal
        }
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = imageSelected
        }
        
        // save photo data
        let imageName = NSUUID().uuidString
        StorageService.savePhotoMessage(image: selectedImageFromPicker, id: imageName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
}


extension ChatViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        cell.playButton.isHidden = messages[indexPath.row].videoUrl == ""
        cell.headerTimeLabel.isHidden = indexPath.row % 3 == 0 ? false : true
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: imagePartner)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 60
        }
        
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage / widthMessage * 250)
        }
        return height
    }
}
