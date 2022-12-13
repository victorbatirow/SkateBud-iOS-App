//
//  UserTableViewCell.swift
//  SkateBud
//
//  Created by Victor on 2022-10-26.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: PeopleTableViewController!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        onlineView.backgroundColor = UIColor.red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }
    
    func loadData(_ user: User) {
        self.user = user
        self.usernameLbl.text  =  user.username
        self.statusLbl.text = user.status
        self.avatar.loadImage(user.profileImageUrl)
        
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
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
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.tableView.reloadData()
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().databaseIsOnline(uid: self.user.uid)
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
