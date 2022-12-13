//
//  UserAroundCollectionViewCell.swift
//  SkateBud
//
//  Created by Victor on 2022-11-26.
//

import UIKit
import Firebase
import CoreLocation

class UserAroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var onlineView: UIImageView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: UsersAroundViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        onlineView.backgroundColor = UIColor.red
        onlineView.layer.cornerRadius = 10/2
        onlineView.clipsToBounds = true
    }
    
    func loadData(_ user: User, currentLocation: CLLocation?) {
        self.user = user
        self.avatar.loadImage(user.profileImageUrl)
        self.avatar.loadImage(user.profileImageUrl) { (image) in
            user.profileImage = image
        }
        if let age = user.age {
            self.ageLbl.text = "\(age)"
        } else {
            self.ageLbl.text = ""
        }
        
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
                self.controller.collectionView.reloadData()
            }
        })
        
        guard let _ = currentLocation else {
            return
        }
        
        if !user.latitude.isEmpty && !user.longitude.isEmpty {
            let userLocation = CLLocation(latitude: Double(user.latitude)!, longitude: Double(user.longitude)!)
            let distanceInKM: CLLocationDistance = userLocation.distance(from: currentLocation!) / 1000
            distanceLbl.text = String(format: "%.0f km", distanceInKM)
        } else {
            distanceLbl.text = ""
        }
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
}
