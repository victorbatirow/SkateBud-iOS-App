//
//  Card.swift
//  SkateBud
//
//  Created by Victor on 2022-12-05.
//

import UIKit
import CoreLocation

class Card: UIView {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    
    var controller: RadarViewController!
    
    var user: User! {
        didSet {
            photo.loadImage(user.profileImageUrl) { (image) in
                self.user.profileImage = image
            }
            
            let attributedUsernameText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor : UIColor.white])
            
            var age = ""
            if let ageValue = user.age {
                age = String(ageValue)
            }
            let attributedAgeText = NSMutableAttributedString(string: age, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.white])
            attributedUsernameText.append(attributedAgeText)
            usernameLbl.attributedText = attributedUsernameText
            
            if let userLat = UserDefaults.standard.value(forKey: "latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "longitude") as? String {
                let currentLocation: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
                if !user.latitude.isEmpty && !user.longitude.isEmpty {
                    
                    let userLoc = CLLocation(latitude: Double(user.latitude)!, longitude: Double(user.longitude)!)
                    let distanceInKM: CLLocationDistance = userLoc.distance(from: currentLocation) / 1000
                    // let KMIntoMiles = distanceInKM * 0.6214
                    locationLbl.text = "\(Int(distanceInKM)) KM away"
                } else {
                    locationLbl.text = ""
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bounds.height)
        photo.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true
    }
    
    @IBAction func infoBtnDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
        detailVC.user = user

        self.controller.navigationController?.pushViewController(detailVC, animated: true)
    }
    

}
