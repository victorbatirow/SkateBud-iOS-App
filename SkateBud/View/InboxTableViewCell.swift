//
//  InboxTableViewCell.swift
//  SkateBud
//
//  Created by Victor on 2022-11-14.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var inboxChangedMessageHandle: DatabaseHandle!
    
    var inbox: Inbox!
    var controller: MessagesTableViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        onlineView.backgroundColor = UIColor.red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }
    
    func configureCell(uid: String, inbox: Inbox) {
        self.user = inbox.user
        self.inbox = inbox
        avatar.loadImage(inbox.user.profileImageUrl)
        usernameLabel.text = inbox.user.username
        let date = Date(timeIntervalSince1970: inbox.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
        if !inbox.text.isEmpty {
            messageLabel.text = inbox.text
        } else {
            messageLabel.text = "[MEDIA]"
        }
        
        // update inbox last message received on inbox cell
//        let refInbox = Ref().databaseInboxInFor(from: Api.User.currentUserId, to: inbox.user.uid)
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        
        
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
        
        inboxChangedMessageHandle = refInbox.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value {
                self.inbox.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
        let refOnline = Ref().databaseIsOnline(uid: inbox.user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.onlineView.backgroundColor = active == true ? .green : .red
                }
            }
        }
        
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        inboxChangedOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool) == true ? .green : .red
                }
            }
        }
        
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let refOnline = Ref().databaseIsOnline(uid: self.inbox.user.uid)
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
